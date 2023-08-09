# require "../../../wndata/models/zh_book"
require "../../../_util/book_util"
require "../../../_data/wnovel/wninfo"

class CV::WninfoForm
  include JSON::Serializable

  getter wn_id : Int32 = 0

  getter btitle_zh : String
  getter btitle_vi : String?

  getter author_zh : String
  getter author_vi : String?

  getter intro_zh : String?
  getter intro_vi : String?

  getter genres : Array(String)? = nil
  getter bcover : String? = nil
  getter status : Int32? = nil

  getter origins : Array(String) = [] of String

  def after_initialize
    @author_zh, @btitle_zh = BookUtil.fix_names(author: @author_zh, btitle: @btitle_zh)

    @author_vi = nil if @author_vi.try(&.blank?)
    @btitle_vi = nil if @btitle_vi.try(&.blank?)

    @intro_vi = nil if @intro_vi.try(&.blank?)

    gen_vi_data! unless @author_vi && @btitle_vi && @intro_vi
  end

  alias ViData = NamedTuple(btitle: String, author: String, bintro: String)

  def gen_vi_data!
    link = "#{CV_ENV.m1_host}/_m1/qtran/tl_wnovel?wn_id=#{@wn_id}"

    headers = HTTP::Headers{"Content-Type" => "application/json"}
    body = {btitle: @btitle_zh, author: @author_zh, bintro: @intro_zh || ""}

    HTTP::Client.post(link, headers: headers, body: body.to_json) do |res|
      return unless res.success?
      data = ViData.from_json(res.body_io.gets_to_end)

      @author_vi ||= data[:author]
      @btitle_vi ||= data[:btitle]
      @intro_vi ||= data[:bintro]
    end
  end

  def save!(_uname : String, _privi : Int32) : Wninfo
    Author.upsert!(@author_zh, @author_vi)
    Btitle.upsert!(@btitle_zh, @btitle_vi)

    wninfo = Wninfo.upsert!(@author_zh, @btitle_zh, name_fixed: true)

    @author_vi.try { |x| wninfo.author_vi = x }
    @btitle_vi.try { |x| wninfo.btitle_vi = x }

    @intro_zh.try do |intro|
      intro = TextUtil.split_html(intro, true).join('\n')
      wninfo.zintro = intro unless intro.blank?
    end

    @intro_vi.try do |intro|
      intro = intro.split(/\R/).map(&.strip).join('\n')
      wninfo.bintro = intro unless intro.blank?
    end

    @genres.try do |genres|
      vi_genres = genres.map!(&.strip).reject!(&.empty?)
      vi_genres = ["Loại khác"] if vi_genres.empty?

      # zh_genres = GenreMap.vi_to_zh(vi_genres)
      # @zh_user.genres = zh_genres.join("\t")
      # @zh_base.genres = zh_genres.join("\t")

      wninfo.vgenres = vi_genres
      wninfo.igenres = GenreMap.map_int(vi_genres)
    end

    @bcover.try do |bcover|
      wninfo.set_bcover(bcover, force: true)
      wninfo.cache_cover(bcover, persist: false)
    end

    @status.try do |status|
      wninfo.set_status(status.to_i, force: true)
    end

    wninfo.tap(&.save!)
  end
end

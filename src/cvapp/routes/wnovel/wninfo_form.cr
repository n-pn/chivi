# require "../../../wndata/models/zh_book"
require "../../../_data/wnovel/wninfo"

class CV::WninfoForm
  include JSON::Serializable

  getter wn_id : Int32 = 0

  getter ztitle : String
  getter vtitle : String?

  getter zauthor : String
  getter vauthor : String?

  getter zintro : String?
  getter vintro : String?

  getter genres : Array(String)? = nil
  getter bcover : String? = nil
  getter status : Int32? = nil

  getter origins : Array(String) = [] of String

  def after_initialize
    @ztitle, @zauthor = BookUtil.fix_names(@ztitle, @zauthor)

    @vauthor = nil if @vauthor.try(&.blank?)
    @vtitle = nil if @vtitle.try(&.blank?)
    @vintro = nil if @vintro.try(&.blank?)

    gen_vi_data! unless @vauthor && @vtitle && @vintro
  end

  alias ViData = NamedTuple(btitle: String, author: String, bintro: String)

  def gen_vi_data!
    link = "#{CV_ENV.m1_host}/_m1/qtran/tl_wnovel?wn_id=#{@wn_id}"

    headers = HTTP::Headers{"Content-Type" => "application/json"}
    body = {btitle: @ztitle, author: @zauthor, bintro: @zintro || ""}

    HTTP::Client.post(link, headers: headers, body: body.to_json) do |res|
      return unless res.success?
      data = ViData.from_json(res.body_io.gets_to_end)

      @vauthor ||= data[:author]
      @vtitle ||= data[:btitle]
      @vintro ||= data[:bintro]
    end
  end

  def save!(_uname : String, _privi : Int32) : Wninfo
    author = Author.upsert!(@zauthor, @vauthor)
    btitle = Btitle.upsert!(@ztitle, @vtitle)

    vi_book = Wninfo.upsert!(author, btitle, fix_names: true)

    @zintro.try do |intro|
      intro = TextUtil.split_html(intro, true).join('\n')
      vi_book.zintro = intro unless intro.blank?
    end

    @vintro.try do |intro|
      intro = intro.split(/\R/).map(&.strip).join('\n')
      vi_book.bintro = intro unless intro.blank?
    end

    @genres.try do |genres|
      vi_genres = genres.map!(&.strip).reject!(&.empty?)
      vi_genres = ["Loại khác"] if vi_genres.empty?

      # zh_genres = GenreMap.vi_to_zh(vi_genres)
      # @zh_user.genres = zh_genres.join("\t")
      # @zh_base.genres = zh_genres.join("\t")

      vi_book.vgenres = vi_genres
      vi_book.igenres = GenreMap.map_int(vi_genres)
    end

    @bcover.try do |bcover|
      vi_book.set_bcover(bcover, force: true)
      vi_book.cache_cover(bcover, persist: false)
    end

    @status.try do |status|
      vi_book.set_status(status.to_i, force: true)
    end

    # TODO: wite text log
    # File.append("var/.keep/web_log/books-upsert.tsv", @params.to_json)

    vi_book.tap(&.save!)
  end
end

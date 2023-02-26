# require "../../../wndata/models/zh_book"
require "../../../_data/wnovel/nv_info"

class CV::NvinfoForm
  include JSON::Serializable

  getter btitle_zh : String
  getter btitle_vi : String?

  getter author_zh : String
  getter author_vi : String?

  getter bintro_zh : String?
  getter bintro_vi : String?

  getter genres : String? = nil

  getter bcover : String? = nil
  getter status : Int32? = nil

  @[JSON::Field(ignore: true)]
  getter! vi_book : Nvinfo

  def after_initialize
    @btitle_zh, @author_zh = BookUtil.fix_names(@btitle_zh, @author_zh)

    @author_vi = nil if @author_vi.try(&.blank?)
    @btitle_vi = nil if @btitle_vi.try(&.blank?)

    @bintro_zh = nil if @bintro_zh.try(&.blank?)
    @bintro_vi = nil if @bintro_vi.try(&.blank?)

    @vi_book = init_nv_book(force: true)
  end

  private def init_nv_book(force : Bool)
    author = Author.upsert!(@author_zh, @author_vi)
    btitle = Btitle.upsert!(@btitle_zh, @btitle_vi)

    vi_book = Nvinfo.upsert!(author, btitle, fix_names: true)

    @bintro_zh.try do |intro|
      vi_book.zintro = TextUtil.split_html(intro, true).join('\n')
    end

    @bintro_vi.try do |intro|
      vi_book.zintro = intro.split(/\R/).join('\n')
    end

    @genres.try do |genres|
      vi_genres = genres.split(",").map!(&.strip)

      # zh_genres = GenreMap.vi_to_zh(vi_genres)
      # @zh_user.genres = zh_genres.join("\t")
      # @zh_base.genres = zh_genres.join("\t")

      vi_book.vgenres = vi_genres
      vi_book.igenres = GenreMap.map_int(vi_genres)
    end

    @bcover.try { |x| vi_book.set_bcover(x, force: force) unless x.blank? }
    @status.try { |x| vi_book.set_status(x.to_i, force: force) }

    vi_book
  end

  def save : Nvinfo?
    # TODO: wite text log
    # File.append("var/.keep/web_log/books-upsert.tsv", @params.to_json)

    vi_book.tap(&.save!)
  end
end

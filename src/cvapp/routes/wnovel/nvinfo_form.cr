# require "../../../wndata/models/zh_book"
require "../../../_data/wnovel/nv_info"

class CV::NvinfoForm
  include JSON::Serializable

  getter btitle_zh : String
  getter btitle_vi : String?

  getter author_zh : String
  getter author_vi : String?

  getter bintro : String?
  getter genres : String?
  getter bcover : String?
  getter status : String?

  @[JSON::Field(ignore: true)]
  getter! vi_book : Nvinfo

  def after_initialize
    @btitle_zh, @author_zh = BookUtil.fix_names(@btitle_zh, @author_zh)

    @author_vi.try { |x| BookUtil.vi_authors.append!(@author_zh, x) }
    @btitle_vi.try { |x| BookUtil.vi_btitles.append!(@btitle_zh, x) }

    @vi_book = init_nv_book(force: true)
  end

  private def init_nv_book(force : Bool)
    author = Author.upsert!(@author_zh, @author_vi)
    btitle = Btitle.upsert!(@btitle_zh, @btitle_vi)

    vi_book = Nvinfo.upsert!(author, btitle, fix_names: true)

    @bintro.try do |intro|
      intro = TextUtil.split_html(intro, true)
      vi_book.set_bintro(intro, force: force)
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

# require "../../../wndata/models/zh_book"
require "../../../_data/wnovel/nv_info"

class CV::WnovelForm
  include JSON::Serializable

  getter btitle_zh : String
  getter btitle_vi : String?

  getter author_zh : String
  getter author_vi : String?

  getter bintro_zh : String?
  getter bintro_vi : String?

  getter genres : Array(String)? = nil
  getter bcover : String? = nil
  getter status : Int32? = nil

  def after_initialize
    @btitle_zh, @author_zh = BookUtil.fix_names(@btitle_zh, @author_zh)
    @author_vi = nil if @author_vi.try(&.blank?)
    @btitle_vi = nil if @btitle_vi.try(&.blank?)
  end

  def save : Nvinfo?
    author = Author.upsert!(@author_zh, @author_vi)
    btitle = Btitle.upsert!(@btitle_zh, @btitle_vi)

    vi_book = Nvinfo.upsert!(author, btitle, fix_names: true)

    @bintro_zh.try do |intro|
      intro = TextUtil.split_html(intro, true).join('\n')
      vi_book.zintro = intro unless intro.blank?
    end

    @bintro_vi.try do |intro|
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
      vi_book.set_bcover(bcover, force: true) unless bcover.blank?
    end

    @status.try do |status|
      vi_book.set_status(status.to_i, force: true)
    end

    # TODO: wite text log
    # File.append("var/.keep/web_log/books-upsert.tsv", @params.to_json)

    vi_book.tap(&.save!)
  end
end

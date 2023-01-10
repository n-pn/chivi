require "../../zhlib/models/zh_book"
require "../../appcv/nv_info"

class CV::NvinfoForm
  getter vi_book : Nvinfo

  # getter zh_user : ZH::ZhBook
  # getter zh_base : ZH::ZhBook

  def initialize(@params : HTTP::Params, @uname = "users")
    btitle_zh = get_param("btitle_zh").not_nil!
    author_zh = get_param("author_zh").not_nil!

    @vi_book = init_vi_book!(btitle_zh, author_zh)
    @book_id = @vi_book.id.to_i

    # @zh_user = init_zh_book("=user", @book_id, btitle_zh, author_zh)
    # @zh_base = init_zh_book("=base", @book_id, btitle_zh, author_zh)
  end

  def init_vi_book!(btitle_zh : String, author_zh : String) : Nvinfo
    btitle_zh, author_zh = BookUtil.fix_names(btitle_zh, author_zh)

    author = get_author(author_zh)
    btitle = get_btitle(btitle_zh)

    Nvinfo.upsert!(author, btitle, fix_names: true)
  end

  private def get_author(author_zh : String)
    author_vi = get_param("author_vi")
    BookUtil.vi_authors.append!(author_zh, author_vi) if author_vi
    Author.upsert!(author_zh, author_vi)
  end

  private def get_btitle(btitle_zh : String)
    btitle_vi = get_param("btitle_vi")
    BookUtil.vi_btitles.append!(btitle_zh, btitle_vi) if btitle_vi
    Btitle.upsert!(btitle_zh, btitle_vi)
  end

  def init_zh_book(sname : String, s_bid : Int32, btitle : String, author : String)
    ZH::ZhBook.load(sname, s_bid).tap do |x|
      x.btitle = btitle
      x.author = author
    end
  end

  def add_bintro(bintro : String?)
    return unless bintro
    bintro = TextUtil.split_html(bintro, true)

    # @zh_user.bintro = bintro.join("\n")
    # @zh_base.bintro = bintro.join("\n")

    @vi_book.set_bintro(bintro, force: true)
  end

  def add_genres(genres : String?)
    return unless genres

    vi_genres = genres.split(",").map!(&.strip)

    # zh_genres = GenreMap.vi_to_zh(vi_genres)
    # @zh_user.genres = zh_genres.join("\t")
    # @zh_base.genres = zh_genres.join("\t")

    @vi_book.vgenres = vi_genres
    @vi_book.igenres = GenreMap.map_int(vi_genres)
  end

  def add_bcover(bcover : String?)
    return if !bcover || bcover.blank?

    # @zh_user.genres = bcover
    # @zh_base.genres = bcover

    @vi_book.set_bcover(bcover, force: true)
  end

  def add_status(status : Int32?)
    return unless status

    # @zh_user.status = status
    # @zh_base.status = status

    @vi_book.set_status(status, force: true)
  end

  private def get_param(param_name : String)
    return unless value = @params[param_name]?
    value = TextUtil.fix_spaces(value).strip
    value unless value.empty?
  end

  def save : Nvinfo?
    self.add_bintro(get_param("bintro"))
    self.add_genres(get_param("genres"))
    self.add_bcover(get_param("bcover"))
    self.add_status(get_param("status").try(&.to_i?))

    # @zh_user.save!
    # @zh_base.save!

    # TODO: wite text log
    # File.append("var/.keep/web_log/books-upsert.tsv", @params.to_json)

    @vi_book.tap(&.save!)
  end
end

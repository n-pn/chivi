require "../../_init/books/book_info"

class CV::NvinfoForm
  getter params : Amber::Validators::Params
  getter errors : String = ""
  getter nvinfo : Nvinfo

  @user_log : BookInfo
  @base_log : BookInfo

  LOG_DIR = "var/books/infos"

  def get_param(param_name : String)
    return unless value = params[param_name]?
    value = TextUtil.fix_spaces(value).strip
    value unless value.empty?
  end

  def initialize(@params, @uname = "users")
    btitle_zh = get_param("btitle_zh").not_nil!
    author_zh = get_param("author_zh").not_nil!
    @nvinfo = init!(btitle_zh, author_zh)

    @user_log = book_info_log(@uname, nvinfo.id.to_i, btitle_zh, author_zh)
    @base_log = book_info_log("=base", nvinfo.id.to_i, btitle_zh, author_zh)
  end

  def book_info_log(sname : String, s_bid : Int32, btitle : String, author : String)
    info = BookInfo.new("#{LOG_DIR}/#{sname}/#{s_bid}.tsv")

    info.set_btitle(btitle)
    info.set_author(author)

    info
  end

  def init!(btitle_zh : String, author_zh : String) : Nvinfo
    btitle_zh, author_zh = BookUtil.fix_names(btitle_zh, author_zh)

    author = get_author(author_zh)
    btitle = get_btitle(btitle_zh)

    Nvinfo.upsert!(author, btitle, fix_names: true)
  end

  def get_author(author_zh : String)
    author_vi = get_param("author_vi")
    BookUtil.vi_authors.append!(author_zh, author_vi) if author_vi
    Author.upsert!(author_zh, author_vi)
  end

  def get_btitle(btitle_zh : String)
    btitle_vi = get_param("btitle_vi")
    BookUtil.vi_btitles.append!(btitle_zh, btitle_vi) if btitle_vi
    Btitle.upsert!(btitle_zh, btitle_vi)
  end

  def save_bintro(bintro = get_param("bintro"))
    return unless bintro
    bintro = TextUtil.split_html(bintro, true)

    @user_log.set_bintro(bintro)
    @base_log.set_bintro(bintro)

    nvinfo.set_bintro(bintro, force: true)
  end

  def save_genres(genres = get_param("genres"))
    return unless genres

    vi_genres = genres.split(",").map!(&.strip)
    zh_genres = GenreMap.vi_to_zh(vi_genres)

    @user_log.set_genres(zh_genres)
    @base_log.set_genres(zh_genres)

    @nvinfo.vgenres = vi_genres
    @nvinfo.igenres = GenreMap.map_int(vi_genres)
  end

  def save_bcover(bcover = get_param("bcover"))
    return unless bcover
    bcover = TextUtil.fix_spaces(bcover).strip

    @user_log.set_bcover(bcover)
    @base_log.set_bcover(bcover)

    @nvinfo.set_bcover(bcover, force: true)
  end

  def save_status(status = get_param("status"))
    return unless status
    status = TextUtil.fix_spaces(status).strip.to_i

    @user_log.set_status(status)
    @base_log.set_status(status)

    @nvinfo.set_status(status, force: true)
  end

  def save(uname = "users") : Nvinfo?
    save_bintro
    save_genres
    save_bcover
    save_status

    @nvinfo.tap(&.save!)
  rescue err
    @errors = err.message || "Unknown error"
    nil
  end
end

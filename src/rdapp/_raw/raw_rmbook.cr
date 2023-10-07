require "./_remote"

class RawRmbook
  def self.init(sname : String, s_bid : String | Int32, stale : Time = Time.utc - 1.years)
    host = Rmhost.from_name!(sname)

    bpath = host.make_book_path(s_bid)
    bfile = host.book_file_path(s_bid)

    Dir.mkdir_p(File.dirname(bfile))
    html = host.load_page(bpath, bfile, stale: stale)
    new(html, host: host)
  end

  def self.new(html : String, sname : String)
    new(html, Rmhost.from_name!(sname))
  end

  def initialize(html : String, @host : Rmhost)
    @page = Rmpage.new(html)
  end

  getter btitle : String do
    btitle = @page.get!(@host.book_btitle).sub(/(作\s+者[：:].+$|最新章节\s*)/, "")

    # TODO: normalize data
    Rmutil.clean_text(btitle)
  end

  getter author : String do
    author = @page.get!(@host.book_author).sub(/作\s*者：/, "")

    # TODO: normalize data
    Rmutil.clean_text(author)
  end

  getter latest_cid : String { @host.extract_cid(@page.get!(@host.book_latest)) }

  getter status_str : String do
    return "" unless matcher = @host.book_status
    @page.get!(matcher)
      .sub(/(文章)?状态：\s*/, "")
      .sub(/^.+\s+\|\s+/, "")
  end

  getter status_int : Int16 { Rmutil.parse_status(status_str) }

  getter update_str : String do
    return "" unless matcher = @host.book_update
    @page.get!(matcher)
      .sub(/^\s*更新(时间)?\s*[: ：]\s*/, "")
      .sub("最后更新：", "")
  end

  getter update_int : Int64 { Rmutil.parse_rmtime(update_str, @host.time_fmt) }

  getter cover : String do
    case cover = @page.get!(@host.book_cover)
    when .starts_with?("http") then cover
    when .starts_with?("//")   then "https#{cover}"
    else                            @host.full_url(cover)
    end
  end

  getter intro : String do
    case @host.seedname
    when "!paotian.com"
      node = @page.find!(@host.book_intro[0])
      node.children.each { |child| child.remove! if child.tag_sym.in?(:span, :a) }
      Rmutil.clean_para(node.inner_text('\n'))
    else
      Rmutil.clean_para(@page.get!(@host.book_intro))
    end
  end

  getter genre : String do
    genre = @page.get!(@host.book_genre).sub(/类\s*别：/, "")
    genre.starts_with?('轻') ? genre : genre.sub("小说", "")
  end

  getter xtags : String do
    @host.book_xtags.try { |extractor| @page.get(extractor) } || ""
  end
end

require "uri"
require "colorize"

require "./rmconf"
require "./rmpage"

class RawRmbook
  def self.init(sname : String, s_bid : String | Int32, stale : Time = Time.utc - 1.years)
    conf = Rmconf.load!(sname)

    bpath = conf.make_book_path(s_bid)
    bfile = conf.book_file_path(s_bid)

    Dir.mkdir_p(File.dirname(bfile))
    html = conf.load_page(bpath, bfile, stale: stale)
    new(html, conf: conf)
  end

  def self.new(html : String, sname : String)
    new(html, Rmconf.load!(sname))
  end

  def initialize(html : String, @conf : Rmconf)
    @page = Rmpage.new(html)
  end

  getter btitle : String do
    btitle =
      @page.get!(@conf.book_btitle)
        .sub(/(作\s+者[：:].+$|最新章节\s*)/, "")

    # TODO: normalize data
    Rmutil.clean_text(btitle)
  end

  getter author : String do
    author =
      @page.get!(@conf.book_author)
        .sub(/作\s*者：/, "")

    # TODO: normalize data
    Rmutil.clean_text(author)
  end

  getter latest_cid : String { @conf.extract_cid(@page.get!(@conf.book_latest)) }

  getter status_str : String do
    return "" unless matcher = @conf.book_status
    @page.get!(matcher)
      .sub(/(文章)?状态：\s*/, "")
      .sub(/^.+\s+\|\s+/, "")
  end

  getter update_str : String do
    return "" unless matcher = @conf.book_update
    @page.get!(matcher)
      .sub(/^\s*更新(时间)?\s*[: ：]\s*/, "")
      .sub("最后更新：", "")
  end

  getter update_int : Int64 do
    update_str = self.update_str
    update_str.empty? ? 0_i64 : @conf.parse_time(update_str).to_unix
  rescue ex
    puts [update_str, ex]
    0_i64
  end

  getter cover : String do
    case cover = @page.get!(@conf.book_cover)
    when .starts_with?("http") then cover
    when .starts_with?("//")   then "https#{cover}"
    else                            @conf.full_path(cover)
    end
  end

  getter intro : String do
    case @conf.seedname
    when "!ptwxz"
      node = @page.find!(@conf.book_intro[0])
      node.children.each { |child| child.remove! if child.tag_sym.in?(:span, :a) }
      Rmutil.clean_para(node.inner_text('\n'))
    else
      Rmutil.clean_para(@page.get!(@conf.book_intro))
    end
  end

  getter genre : String do
    genre = @page.get!(@conf.book_genre).sub(/类\s*别：/, "")
    genre.starts_with?('轻') ? genre : genre.sub("小说", "")
  end

  getter xtags : String do
    @conf.book_xtags.try { |extractor| @page.get(extractor) } || ""
  end
end

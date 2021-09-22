require "../cutil/http_util"
require "../cutil/site_link"
require "../cutil/path_util"
require "../cutil/time_utils"
require "./shared/html_parser"

class CV::RmInfo
  def self.mkdir!(sname : String)
    FileUtils.mkdir_p(PathUtil.cache_dir(sname, "infos"))
  end

  TTL = 1.years

  def self.binfo_html(sname : String, snvid : String, ttl = TTL, lbl = "1/1")
    file = PathUtil.binfo_cpath(sname, snvid)
    GzipFile.new(file).read(ttl) do
      url = SiteLink.binfo_url(sname, snvid)
      encoding = HttpUtil.encoding_for(sname)
      HttpUtil.get_html(url, encoding: encoding, lbl: lbl)
    end
  end

  def self.chidx_html(sname : String, snvid : String, ttl = TTL, lbl = "1/1")
    file = PathUtil.chdix_cpath(sname, snvid)
    GzipFile.new(file).read(ttl) do
      url = SiteLink.chidx_url(sname, snvid)
      encoding = HttpUtil.encoding_for(sname)
      HttpUtil.get_html(url, encoding: encoding, lbl: lbl)
    end
  end

  def self.init(sname : String, snvid : String, ttl = TTL, lbl = "1/1", full = true)
    ihtml = binfo_html(sname, snvid, ttl, lbl)
    chtml = chidx_html(sname, snvid, ttl, lbl) if full && sname == "69shu"
    new(sname, snvid, ihtml, chtml)
  end

  def initialize(@sname, @snvid, binfo_html : String, chidx_html : String? = nil)
    @ipage = HtmlParser.new(binfo_html)
    @cpage = chidx_html ? HtmlParser.new(chidx_html) : @ipage
  end

  getter sname : String
  getter snvid : String

  getter btitle : String do
    case @sname
    when "zhwenpg" then @ipage.text(".cbooksingle h2")
    when "hetushu" then @ipage.text("h2")
    when "69shu"
      @ipage.text("h1 > a", nil) || @ipage.text(".weizhi > a:last-child")
    else
      @ipage.meta("og:novel:book_name").sub(/作\s+者[：:].+$/, "")
    end
  end

  getter author : String do
    case @sname
    when "zhwenpg" then @ipage.text(".fontwt")
    when "hetushu" then @ipage.text(".book_info a:first-child")
    when "69shu"
      @ipage.text(".booknav2 > p:nth-child(2) > a", nil) || @ipage.text(".mu_beizhu > a[target]")
    else
      @ipage.meta("og:novel:author")
    end
  end

  getter genres : Array(String) do
    case @sname
    when "zhwenpg" then [] of String
    when "hetushu"
      genre = @ipage.text(".title > a:last-child")
      tags = @ipage.text_list(".tag a")
      [genre].concat(tags).uniq
    when "69shu"
      genre = @ipage.text(".booknav2 > p:nth-child(3) > a", nil)
      [genre || @ipage.text(".weizhi > a:nth-child(2)")]
    else
      [@ipage.meta("og:novel:category")]
    end
  end

  getter bintro : Array(String) do
    case @sname
    when "hetushu" then @ipage.text_list(".intro > p")
    when "zhwenpg" then @ipage.text_para("tr:nth-of-type(3)")
    when "bxwxorg" then @ipage.text_para("#intro > p:first-child")
    when "69shu"   then @ipage.text_para(".navtxt > p:first-child")
    else                @ipage.meta_para("og:description")
    end
  end

  getter bcover : String do
    case @sname
    when "hetushu"
      "https://www.hetushu.com#{@ipage.attr(".book_info img", "src")}"
    when "69shu"
      image_url = "/#{@snvid.to_i // 1000}/#{@snvid}/#{@snvid}s.jpg"
      "https://www.69shu.com/files/article/image/#{image_url}"
    when "zhwenpg"
      @ipage.attr(".cover_wrapper_m img", "data-src")
    when "jx_la"
      @ipage.meta("og:image").sub("qu.la", "jx.la")
    else
      @ipage.meta("og:image")
    end
  end

  getter status : String do
    case @sname
    when "zhwenpg" then "0"
    when "69shu"
      @ipage.text(".booknav2 > p:nth-child(4)").split("  |  ").last
    when "hetushu"
      @ipage.attr(".book_info", "class").includes?("finish") ? "1" : "0"
    else
      @ipage.meta("og:novel:status")
    end
  end

  getter update : String do
    case @sname
    when "69shu"
      @ipage.text(".booknav2 > p:nth-child(5)").sub("更新：", "")
    when "bqg_5200"
      @ipage.text("#info > p:last-child").sub("最后更新：", "")
    else
      @ipage.meta("og:novel:update_time")
    end
  end

  getter mftime : Int64 do
    return 0_i64 if @sname == "hetushu" || @sname == "zhwenpg"

    updated_at = TimeUtils.parse_time(update)
    updated_at += 12.hours if @sname == "bqg_5200" || @sname == "69shu"

    upper_time = Time.utc - 1.minutes
    updated_at < upper_time ? updated_at.to_unix : upper_time.to_unix
  rescue
    0_i64
  end

  getter last_schid : String { extract_schid(last_schid_href) }

  def last_schid_href
    case @sname
    when "69shu"    then @ipage.attr(".qustime a:first-child", "href")
    when "hetushu"  then @ipage.attr("#dir :last-child a:last-of-type", "href")
    when "zhwenpg"  then @ipage.attr(".fontwt0 + a", "href")
    when "bqg_5200" then @ipage.attr("#list a:first-of-type", "href")
    else                 @ipage.meta("og:novel:latest_chapter_url")
    end
  end

  private def extract_schid(href : String)
    case @sname
    when "zhwenpg" then href.sub("r.php?id=", "")
    when "69shu"   then File.basename(href)
    else                File.basename(href, ".html")
    end
  end

  alias Chinfo = Array(String)

  def init_chap(schid : String, title : String, label : String = "")
    label = TextUtils.fix_spaces(label).strip
    title, label = TextUtils.format_title(title, label)
    label = label.sub(/\s{2,}/, " ")

    [schid, title, label]
  end

  def valid_chap?(info : Chinfo)
    return false unless title = info[1]?
    !title.empty?
  end

  getter chap_list : Array(Chinfo) do
    case @sname
    when "69shu"   then extract_69shu_chaps
    when "zhwenpg" then extract_zhwenpg_chaps
    when "duokan8" then extract_duokan8_chaps
    when "hetushu" then extract_generic_chaps("#dir")
    when "5200"    then extract_generic_chaps(".listmain > dl")
    else                extract_generic_chaps("#list > dl")
    end
  end

  def extract_generic_chaps(query : String)
    chaps = [] of Chinfo
    return chaps unless node = @cpage.find(query)

    label = ""

    node.children.each do |node|
      case node.tag_sym
      when :dt
        inner = node.css("b").first? || node
        label = inner.inner_text.gsub(/《.*》/, "")
      when :dd
        next if label.includes?("最新章节")
        next unless link = node.css("a").first?
        next unless href = link.attributes["href"]?

        chap = init_chap(extract_schid(href), link.inner_text, label)
        chaps << chap if valid_chap?(chap)
      end
    rescue err
      puts err.colorize.red
    end

    chaps
  end

  def extract_69shu_chaps
    chaps = [] of Chinfo

    @cpage.css("#catalog li > a").each do |link|
      next unless href = link.attributes["href"]?
      chap = init_chap(extract_schid(href), link.inner_text)
      chaps << chap if valid_chap?(chap)
    end

    chaps
  end

  def extract_zhwenpg_chaps
    chaps = [] of Chinfo

    @cpage.css(".clistitem > a").each do |link|
      href = link.attributes["href"]
      chap = init_chap(extract_schid(href), link.inner_text)
      chaps << chap if valid_chap?(chap)
    end

    # check if the list is in correct orlder
    chaps.reverse! if chaps.first.first == last_schid

    chaps
  end

  private def extract_duokan8_chaps
    chaps = [] of Chinfo

    @cpage.css(".chapter-list a").each do |link|
      next unless href = link.attributes["href"]?
      chap = init_chap(extract_schid(href), link.inner_text)
      chaps << chap if valid_chap?(chap)
    end

    chaps
  end
end

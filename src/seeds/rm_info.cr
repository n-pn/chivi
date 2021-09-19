require "../cutil/http_util"
require "../cutil/site_link"
require "../cutil/time_utils"
require "./shared/html_parser"

class CV::RmInfo
  # cache folder path
  def self.c_dir(sname : String) : String
    "_db/.cache/#{sname}/infos"
  end

  def self.mkdir!(sname : String)
    ::FileUtils.mkdir_p(c_dir(sname))
  end

  getter sname : String
  getter snvid : String

  alias TimeSpan = Time::Span | Time::MonthSpan

  def initialize(@sname, @snvid, @ttl : TimeSpan = 10.years, @label = "1/1")
  end

  getter file : String { "#{RmInfo.c_dir(@sname)}/#{@snvid}.html.gz" }
  getter link : String { SiteLink.book_link(@sname, @snvid) }

  getter page : HtmlParser do
    encoding = HttpUtil.encoding_for(@sname)
    html = HttpUtil.load_html(link, file, @ttl, @label, encoding)
    HtmlParser.new(html)
  end

  getter btitle : String do
    case @sname
    when "zhwenpg" then page.text(".cbooksingle h2")
    when "hetushu" then page.text("h2")
    when "69shu"
      page.text("h1 > a", nil) || page.text(".weizhi > a:last-child")
    else
      page.meta("og:novel:book_name").sub(/作\s+者[：:].+$/, "")
    end
  end

  getter author : String do
    case @sname
    when "zhwenpg" then page.text(".fontwt")
    when "hetushu" then page.text(".book_info a:first-child")
    when "69shu"
      page.text(".booknav2 > p:nth-child(2) > a", nil) || page.text(".mu_beizhu > a[target]")
    else
      page.meta("og:novel:author")
    end
  end

  getter genres : Array(String) do
    case @sname
    when "zhwenpg" then [] of String
    when "hetushu"
      genre = page.text(".title > a:last-child")
      tags = page.text_list(".tag a")
      [genre].concat(tags).uniq
    when "69shu"
      genre = page.text(".booknav2 > p:nth-child(3) > a", nil)
      [genre || page.text(".weizhi > a:nth-child(2)")]
    else
      [page.meta("og:novel:category")]
    end
  end

  getter bintro : Array(String) do
    case @sname
    when "hetushu" then page.text_list(".intro > p")
    when "zhwenpg" then page.text_para("tr:nth-of-type(3)")
    when "bxwxorg" then page.text_para("#intro > p:first-child")
    when "69shu"   then page.text_para(".navtxt > p:first-child")
    else                page.meta_para("og:description")
    end
  end

  getter bcover : String do
    case @sname
    when "hetushu"
      image_url = page.attr(".book_info img", "src")
      "https://www.hetushu.com#{image_url}"
    when "69shu"
      image_url = "/#{@snvid.to_i // 1000}/#{@snvid}/#{@snvid}s.jpg"
      "https://www.69shu.com/files/article/image/#{image_url}"
    when "zhwenpg"
      page.attr(".cover_wrapper_m img", "data-src")
    when "jx_la"
      page.meta("og:image").sub("qu.la", "jx.la")
    else
      page.meta("og:image")
    end
  end

  getter status : String do
    case @sname
    when "zhwenpg" then "0"
    when "69shu"
      page.text(".booknav2 > p:nth-child(4)").split("  |  ").last
    when "hetushu"
      page.attr(".book_info", "class").includes?("finish") ? "1" : "0"
    else
      page.meta("og:novel:status")
    end
  end

  getter update : String do
    case @sname
    when "69shu"
      page.text(".booknav2 > p:nth-child(5)").sub("更新：", "")
    when "bqg_5200"
      page.text("#info > p:last-child").sub("最后更新：", "")
    else
      page.meta("og:novel:update_time")
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

  getter last_schid : String do
    extract_schid(last_schid_href)
  end

  def last_schid_href
    case @sname
    when "69shu"    then page.attr(".qustime a:first-child", "href")
    when "hetushu"  then page.attr("#dir :last-child a:last-of-type", "href")
    when "zhwenpg"  then page.attr(".fontwt0 + a", "href")
    when "bqg_5200" then page.attr("#list a:first-of-type", "href")
    else                 page.meta("og:novel:latest_chapter_url")
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
    return chaps unless node = page.find(query)

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
    page = begin
      link = "https://www.69shu.com/#{@snvid}/"
      file = "_db/.cache/69shu/infos/#{@snvid}-mulu.html.gz"
      html = HttpUtil.load_html(link, file, @ttl, @label, "GBK")
      HtmlParser.new(html)
    end

    chaps = [] of Chinfo

    page.css("#catalog li > a").each do |link|
      next unless href = link.attributes["href"]?
      chap = init_chap(extract_schid(href), link.inner_text)
      chaps << chap if valid_chap?(chap)
    end

    chaps
  end

  def extract_zhwenpg_chaps
    chaps = [] of Chinfo

    page.css(".clistitem > a").each do |link|
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

    page.css(".chapter-list a").each do |link|
      next unless href = link.attributes["href"]?
      chap = init_chap(extract_schid(href), link.inner_text)
      chaps << chap if valid_chap?(chap)
    end

    chaps
  end
end

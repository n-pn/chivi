require "../cutil/time_utils"
require "../cutil/http_utils"
require "../cutil/path_utils"

require "./shared/html_parser"

class CV::RmInfo
  # cache folder path
  def self.c_dir(sname : String) : String
    PathUtils.cache_dir(sname, "infos")
  end

  def self.mkdir!(sname : String)
    ::FileUtils.mkdir_p(c_dir(sname))
  end

  getter sname : String
  getter snvid : String

  alias TimeSpan = Time::Span | Time::MonthSpan

  def initialize(@sname, @snvid, @ttl : TimeSpan = 10.years, @label = "1/1")
  end

  getter info_file : String do
    PathUtils.cache_file(@sname, "infos/#{@snvid}.html.gz")
  end

  getter chap_file : String do
    return info_file unless @sname == "69shu"
    PathUtils.cache_file("69shu", "infos/#{snvid}-mulu.html.gz")
  end

  getter info_link : String do
    case @sname
    when "nofff"    then "https://www.nofff.com/#{snvid}/"
    when "jx_la"    then "https://www.jx.la/book/#{snvid}/"
    when "qu_la"    then "https://www.qu.la/book/#{snvid}/"
    when "69shu"    then "https://www.69shu.com/txt/#{@snvid}.htm"
    when "rengshu"  then "http://www.rengshu.com/book/#{snvid}"
    when "xbiquge"  then "https://www.xbiquge.so/book/#{snvid}/"
    when "biqubao"  then "https://www.biqubao.com/book/#{snvid}/"
    when "bxwxorg"  then "https://www.bxwxorg.com/read/#{snvid}/"
    when "zhwenpg"  then "https://novel.zhwenpg.com/b.php?id=#{snvid}"
    when "hetushu"  then "https://www.hetushu.com/book/#{snvid}/index.html"
    when "duokan8"  then "http://www.duokanba.info/#{scopped_snvid}/"
    when "paoshu8"  then "http://www.paoshu8.com/#{scopped_snvid}/"
    when "5200"     then "https://www.5200.tv/#{scopped_snvid}/"
    when "shubaow"  then "https://www.shubaow.net/#{scopped_snvid}/"
    when "bqg_5200" then "https://www.biquge5200.com/#{scopped_snvid}/"
    else                 raise "Unsupported remote source <#{sname}>!"
    end
  end

  def scopped_snvid
    "#{@snvid.to_i // 1000}_#{@snvid}"
  end

  getter chap_link : String do
    return chap_link unless @sname == "69shu"
    "https://www.69shu.com/#{snvid}/"
  end

  getter info_page : HtmlParser do
    encoding = HttpUtils.encoding_for(@sname)
    html = HttpUtils.load_html(info_link, info_file, @ttl, @label, encoding)

    HtmlParser.new(html)
  end

  getter btitle : String do
    case @sname
    when "zhwenpg" then info_page.text(".cbooksingle h2")
    when "hetushu" then info_page.text("h2")
    when "69shu"
      info_page.text("h1 > a", nil) || info_page.text(".weizhi > a:last-child")
    else
      info_page.meta("og:novel:book_name").sub(/作\s+者[：:].+$/, "")
    end
  end

  getter author : String do
    case @sname
    when "zhwenpg" then info_page.text(".fontwt")
    when "hetushu" then info_page.text(".book_info a:first-child")
    when "69shu"
      info_page.text(".booknav2 > p:nth-child(2) > a", nil) || info_page.text(".mu_beizhu > a[target]")
    else
      info_page.meta("og:novel:author")
    end
  end

  getter genres : Array(String) do
    case @sname
    when "zhwenpg" then [] of String
    when "hetushu"
      genre = info_page.text(".title > a:last-child")
      tags = info_page.text_list(".tag a")
      [genre].concat(tags).uniq
    when "69shu"
      genre = info_page.text(".booknav2 > p:nth-child(3) > a", nil)
      [genre || info_page.text(".weizhi > a:nth-child(2)")]
    else
      [info_page.meta("og:novel:category")]
    end
  end

  getter bintro : Array(String) do
    case @sname
    when "hetushu" then info_page.text_list(".intro > p")
    when "zhwenpg" then info_page.text_para("tr:nth-of-type(3)")
    when "bxwxorg" then info_page.text_para("#intro > p:first-child")
    when "69shu"   then info_page.text_para(".navtxt > p:first-child")
    else                info_page.meta_para("og:description")
    end
  end

  getter bcover : String do
    case @sname
    when "hetushu"
      image_url = info_page.attr(".book_info img", "src")
      "https://www.hetushu.com#{image_url}"
    when "69shu"
      image_url = "/#{@snvid.to_i // 1000}/#{@snvid}/#{@snvid}s.jpg"
      "https://www.69shu.com/files/article/image/#{image_url}"
    when "zhwenpg"
      info_page.attr(".cover_wrapper_m img", "data-src")
    when "jx_la"
      info_page.meta("og:image").sub("qu.la", "jx.la")
    else
      info_page.meta("og:image")
    end
  end

  getter status : String do
    case @sname
    when "zhwenpg" then "0"
    when "69shu"
      info_page.text(".booknav2 > p:nth-child(4)").split("  |  ").last
    when "hetushu"
      info_page.attr(".book_info", "class").includes?("finish") ? "1" : "0"
    else
      info_page.meta("og:novel:status")
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

  getter update : String do
    case @sname
    when "69shu"
      info_page.text(".booknav2 > p:nth-child(5)").sub("更新：", "")
    when "bqg_5200"
      info_page.text("#info > p:last-child").sub("最后更新：", "")
    else
      info_page.meta("og:novel:update_time")
    end
  end
end

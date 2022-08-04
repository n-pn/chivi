require "../../_util/http_util"
require "../../_util/site_link"
require "../../_util/time_util"

require "./remote_mulu"

class CV::RemoteInfo
  DIR = "var/books/.html"
  TTL = 10.years

  def self.mkdir!(sname : String)
    Dir.mkdir_p(File.join(DIR, sname))
  end

  getter root_dir : String
  @ttl : Time::Span | Time::MonthSpan

  getter info_file : String { "#{@root_dir}/#{@snvid}.html.gz" }
  getter info_link : String { SiteLink.info_url(@sname, @snvid) }

  getter mulu_link : String { SiteLink.mulu_url(@sname, @snvid) }
  getter mulu_file : String { "#{@root_dir}/#{@snvid}-mulu.html.gz" }

  def initialize(@sname : String, @snvid : String, @ttl = TTL, @lbl = "-/-")
    @root_dir = File.join(DIR, @sname)
    @encoding = HttpUtil.encoding_for(@sname)
  end

  def changed?(last_schid : String, update_int : Int64)
    return true if self.last_schid != last_schid
    return true if @sname.in?("69shu", "biqu5200", "ptwxz")
    self.update_int != update_int
  end

  getter info : HtmlParser do
    html = HttpUtil.cache(info_file, info_link, @ttl, @lbl, @encoding)
    HtmlParser.new(html)
  rescue
    HtmlParser.new("")
  end

  getter mulu : RemoteMulu do
    RemoteMulu.new(load_mulu_parser, @sname)
  end

  private def load_mulu_parser
    return info unless @sname.in?("69shu", "ptwxz")
    html = HttpUtil.cache(mulu_file, mulu_link, @ttl, @lbl, @encoding)
    HtmlParser.new(html)
  rescue
    HtmlParser.new("")
  end

  getter btitle : String do
    case @sname
    when "ptwxz" then info.text("h1")
    when "69shu"
      info.text("h1 > a") { info.text(".weizhi > a:last-child") }
    when "uukanshu" then info.text("h1").sub(/最新章节\s*/, "")
    when "uuks"     then info.text("h1 > a")
    when "hetushu"  then info.text("h2")
    when "zhwenpg"  then info.text(".cbooksingle h2")
    else
      info.meta("og:novel:book_name").sub(/作\s+者[：:].+$/, "")
    end
  end

  getter ptwxz_info : Lexbor::Node do
    info.css("table[width=\"100%\"]", &.first)
  end

  getter author : String do
    case @sname
    when "ptwxz"    then info.inner_text(ptwxz_info.css("tr:nth-child(2) > td")[1])
    when "uukanshu" then info.text("h2 > a")
    when "69shu"
      info.text(".booknav2 > p:nth-child(2) > a") { info.text(".mu_beizhu > a[target]") }
    when "uuks"    then info.text("h2").sub("作者：", "")
    when "hetushu" then info.text(".book_info a:first-child")
    when "zhwenpg" then info.text(".fontwt")
    else
      info.meta("og:novel:author")
    end
  end

  getter genres : Array(String) do
    case @sname
    when "ptwxz"
      [info.inner_text(ptwxz_info.css("tr:nth-child(2) > td")[0])]
    when "69shu"
      query = ".booknav2 > p:nth-child(3) > a"
      [info.text(query) { info.text(".weizhi > a:nth-child(2)") }]
    when "hetushu"
      bgenre = info.text(".title > a:last-child")
      info.text_list(".tag a").tap(&.unshift(bgenre)).uniq!
    when "uukanshu", "uuks"
      [info.text(".path > a:nth-child(2)").sub("小说", "")]
    when "zhwenpg" then [] of String
    else
      [info.meta("og:novel:category")]
    end
  end

  getter bintro : Array(String) do
    case @sname
    when "ptwxz"
      return [""] unless node = info.find("div[style=\"float:left;width:390px;\"]")
      info.clean_node(node, :span, :a)
      TextUtil.split_html(node.inner_text)
    when "69shu"
      info.text_para(".navtxt > p:first-child")
    when "hetushu"
      info.text_list(".intro > p")
    when "uukanshu"
      intro = info.text_para("h3")
      intro[0] = intro[0].sub(/^.+www\.uukanshu\.com\s*/, "")
      intro.shift if intro[0].empty?
      intro.pop if intro.last =~ /^－+$/
      intro[-1] = intro[-1].sub(/\s*https:\/\/www\.uukanshu\.com.*$/, "")
      intro.pop if intro.last.empty?
      intro
    when "uuks"
      intro = info.text_para("h3")
      intro[0] = intro[0].sub(/^简介：/, "")
      intro.pop if intro.last =~ /^－+$/
      intro
    when "bxwxorg"
      info.text_para("#intro > p:first-child")
    when "zhwenpg"
      info.text_para("tr:nth-of-type(3)")
    else
      info.meta_para("og:description")
    end
  end

  getter bcover : String do
    case @sname
    when "69shu"
      image_path = "/#{@snvid.to_i // 1000}/#{@snvid}/#{@snvid}s.jpg"
      "https://www.69shu.com/files/article/image/#{image_path}"
    when "hetushu"
      "https://www.hetushu.com" + info.attr(".book_info img", "src")
    when "ptwxz"    then info.attr("img[width=\"100\"]", "src")
    when "uukanshu" then "https:" + info.attr(".bookImg > img", "src")
    when "uuks"
      "https://www.uuks.org" + info.attr(".bookImg > img", "src")
    when "133txt"
      info.meta("og:image").sub("https://www.133txt.comhttps://", "https://")
    when "biqugse"
      "http://www.biqugse.com" + info.meta("og:image")
    when "kanshu8"
      "http://www.kanshu8.net" + info.meta("og:image")
    when "zhwenpg" then info.attr(".cover_wrapper_m img", "data-src")
    when "bxwxorg" then "https:" + info.meta("og:image")
    else                info.meta("og:image")
    end
  end

  getter status_str : String do
    case @sname
    when "ptwxz"
      info.inner_text(ptwxz_info.css("tr:nth-child(3) > td").to_a[1])
    when "69shu"
      info.text(".booknav2 > p:nth-child(4)").split("  |  ").last
    when "hetushu"
      info.attr(".book_info", "class").includes?("finish") ? "1" : "0"
    when "uukanshu", "uuks" then "0"
    else
      info.meta("og:novel:status")
    end
  end

  getter status_int : Int8 do
    case status_str
    when "暂停", "暂 停", "暂　停"
      2_i8
    when "完成", "完本", "已经完结", "已经完本",
         "完结", "已完结", "此书已完成", "已完本", "全本",
         "完结申请", "已完成", "1"
      1_i8
    else
      0_i8
    end
  end

  getter update_str : String do
    case @sname
    when "ptwxz"
      info.inner_text(ptwxz_info.css("tr:nth-child(3) > td").to_a[0])
    when "69shu"
      info.text(".booknav2 > p:nth-child(5)").sub("更新：", "")
    when "uukanshu"
      info.text(".shijian").split(" ", 2).first.sub("更新时间：", "")
    when "uuks"
      info.text(".shijian").sub("更新时间：", "")
    when "biqu5200"
      info.text("#info > p:last-child").sub("最后更新：", "")
    when "hetushu", "zhwenpg" then ""
    else
      info.meta("og:novel:update_time")
    end
  end

  getter update_int : Int64 do
    time = TimeUtil.parse_time(update_str)

    if @sname.in?("69shu", "biqu5200", "ptwxz")
      time += 1.day
      tnow = Time.utc - 1.minutes
      time = tnow if time > tnow
    end

    time.to_unix
  rescue
    0_i64
  end

  def last_schid_href : String
    case @sname
    when "ptwxz"
      info.css(".grid a[target]") { |x| x[0].attributes["href"]? || "" }
    when "69shu"
      info.attr(".qustime a:first-child", "href")
    when "uukanshu", "uuks"
      info.attr(".zuixin > a", "href")
    when "biqu5200"
      info.attr("#list a:first-of-type", "href")
    when "kanshu8"
      info.attr(".pt-bookdetail-intro + div a:first-of-type", "href")
    when "hetushu"
      info.attr("#dir :last-child a:last-of-type", "href")
    when "zhwenpg"
      info.attr(".fontwt0 + a", "href")
    else
      info.meta("og:novel:latest_chapter_url")
    end
  end

  getter last_schid : String { mulu.extract_schid(last_schid_href) }
  getter chap_infos : Array(RemoteMulu::Chinfo) { mulu.tap(&.extract_chaps!).chaps }
end

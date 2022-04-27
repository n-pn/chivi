require "../_util/http_util"
require "../_util/site_link"
require "../_util/time_util"

require "./shared/html_parser"
require "../appcv/nvchap/ch_info"
require "../appcv/shared/sname_map"

class CV::RemoteInfo
  DIR = "_db/.cache/%s/infos"
  TTL = 10.years

  getter dir : String
  @ttl : Time::Span | Time::MonthSpan

  def initialize(@sname : String, @snvid : String, @ttl = TTL, @lbl = "-/-")
    @dir = DIR % @sname
    @ttl = 10.years if SnameMap.map_type(@sname) < 3
    @encoding = HttpUtil.encoding_for(@sname)
  end

  getter info : HtmlParser do
    file = "#{@dir}/#{@snvid}.html.gz"
    link = SiteLink.info_url(@sname, @snvid)

    html = HttpUtil.cache(file, link, @ttl, @lbl, @encoding)
    HtmlParser.new(html)
  rescue
    HtmlParser.new("")
  end

  getter mulu : HtmlParser do
    return info unless @sname.in?("69shu", "ptwxz")

    file = "#{@dir}/#{@snvid}-mulu.html.gz"
    link = SiteLink.mulu_url(@sname, @snvid)

    html = HttpUtil.cache(file, link, @ttl, @lbl, @encoding)
    HtmlParser.new(html)
  rescue
    HtmlParser.new("")
  end

  getter btitle : String do
    case @sname
    when "ptwxz"   then info.text("h1")
    when "hetushu" then info.text("h2")
    when "zhwenpg" then info.text(".cbooksingle h2")
    when "69shu"
      info.text("h1 > a") { info.text(".weizhi > a:last-child") }
    else
      info.meta("og:novel:book_name").sub(/作\s+者[：:].+$/, "")
    end
  end

  getter ptwxz_info : Lexbor::Node do
    info.css("table[width=\"100%\"]", &.first)
  end

  getter author : String do
    case @sname
    when "ptwxz"   then info.inner_text(ptwxz_info.css("tr:nth-child(2) > td")[1])
    when "hetushu" then info.text(".book_info a:first-child")
    when "zhwenpg" then info.text(".fontwt")
    when "69shu"
      info.text(".booknav2 > p:nth-child(2) > a") { info.text(".mu_beizhu > a[target]") }
    else
      info.meta("og:novel:author")
    end
  end

  getter genres : Array(String) do
    case @sname
    when "zhwenpg" then [] of String
    when "ptwxz"
      [info.inner_text(ptwxz_info.css("tr:nth-child(2) > td")[0])]
    when "69shu"
      query = ".booknav2 > p:nth-child(3) > a"
      [info.text(query) { info.text(".weizhi > a:nth-child(2)") }]
    when "hetushu"
      bgenre = info.text(".title > a:last-child")
      info.text_list(".tag a").tap(&.unshift(bgenre)).uniq!
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
    when "bxwxorg"
      info.text_para("#intro > p:first-child")
    when "hetushu"
      info.text_list(".intro > p")
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
    when "zhwenpg" then info.attr(".cover_wrapper_m img", "data-src")
    when "ptwxz"   then info.attr("img[width=\"100\"]", "src")
    else                info.meta("og:image")
    end
  end

  getter status_str : String do
    case @sname
    when "zhwenpg" then "0"
    when "ptwxz"
      info.inner_text(ptwxz_info.css("tr:nth-child(3) > td").to_a[1])
    when "69shu"
      info.text(".booknav2 > p:nth-child(4)").split("  |  ").last
    when "hetushu"
      info.attr(".book_info", "class").includes?("finish") ? "1" : "0"
    else
      info.meta("og:novel:status")
    end
  end

  getter status_int : Int32 do
    case status_str
    when "暂停", "暂 停", "暂　停"
      2
    when "完成", "完本", "已经完结", "已经完本",
         "完结", "已完结", "此书已完成", "已完本", "全本",
         "完结申请", "已完成", "1"
      1
    else
      0
    end
  end

  getter update_str : String do
    case @sname
    when "ptwxz"
      info.inner_text(ptwxz_info.css("tr:nth-child(3) > td").to_a[0])
    when "69shu"
      info.text(".booknav2 > p:nth-child(5)").sub("更新：", "")
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
      time += 24.hours
      tnow = Time.utc - 1.minutes
      time < tnow ? time : tnow
    end

    time.to_unix
  rescue
    0_i64
  end

  getter last_schid : String { extract_schid(last_schid_href) }

  def extract_schid(href : String)
    case @sname
    when "zhwenpg" then href.sub("r.php?id=", "")
    when "69shu"   then File.basename(href)
    else                File.basename(href, ".html")
    end
  end

  def last_schid_href : String
    case @sname
    when "ptwxz"
      info.css(".grid a[target]") { |x| x[0].attributes["href"]? || "" }
    when "69shu"
      info.attr(".qustime a:first-child", "href")
    when "biqu5200"
      info.attr("#list a:first-of-type", "href")
    when "hetushu"
      info.attr("#dir :last-child a:last-of-type", "href")
    when "zhwenpg"
      info.attr(".fontwt0 + a", "href")
    else
      info.meta("og:novel:latest_chapter_url")
    end
  end

  getter chap_infos : Array(ChInfo) do
    case @sname
    when "ptwxz"   then extract_chapters_plain(".centent li > a")
    when "69shu"   then extract_chapters_plain("#catalog li > a")
    when "duokan8" then extract_chapters_plain(".chapter-list a")
    when "5200"    then extract_chapters_chvol(".listmain > dl")
    when "hetushu" then extract_chapters_chvol("#dir")
    when "zhwenpg"
      chaps = extract_chapters_plain(".clistitem > a")

      # reverse the list if chap list is reversed
      if chaps.first.schid == last_schid
        chaps.reverse!
        chaps.each_with_index(1) { |chinfo, chidx| chinfo.chidx = chidx }
      end

      chaps
    else
      extract_chapters_chvol("#list > dl")
    end
  end

  def clean_chvol(chvol : String)
    chvol.gsub(/《.*》/, "").gsub(/\n|\t|\s{3,}/, "  ").strip
  end

  def extract_chapters_chvol(selector : String)
    chaps = [] of ChInfo
    return chaps unless body = mulu.find(selector)

    chvol = ""
    body.children.each do |node|
      case node.tag_sym
      when :dt
        inner = node.css("b").first? || node
        chvol = clean_chvol(inner.inner_text)
      when :dd
        next if chvol.includes?("最新章节")
        next unless link = node.css("a").first?
        next unless href = link.attributes["href"]?

        chap = ChInfo.new(chaps.size + 1, extract_schid(href), link.inner_text, chvol)
        chaps << chap unless chap.invalid?
      end
    rescue err
      puts err.colorize.red
    end

    chaps
  end

  def extract_chapters_plain(selector : String)
    chaps = [] of ChInfo

    mulu.css(selector).each do |link|
      href = link.attributes["href"]
      chap = ChInfo.new(chaps.size + 1, extract_schid(href), link.inner_text)
      chaps << chap unless chap.invalid?
    rescue err
      puts err.colorize.red
    end

    chaps
  end
end

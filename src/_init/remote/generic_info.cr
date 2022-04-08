require "../shared/html_parser"
require "../../appcv/nvchap/ch_info"

class CV::RmInfoGeneric
  def initialize(info_html : String, mulu_html : String? = nil)
    @info = HtmlParser.new(info_html)
    @mulu = mulu_html ? HtmlParser.new(mulu_html) : @info
  end

  def btitle : String
    @info.meta("og:novel:book_name").sub(/作\s+者[：:].+$/, "")
  end

  def author : String
    @info.meta("og:novel:author")
  end

  def genres : Array(String)
    [@info.meta("og:novel:category")]
  end

  def bintro : Array(String)
    @info.meta_para("og:description")
  end

  def bcover : String
    @info.meta("og:image")
  end

  getter status_str : String { @info.meta("og:novel:status") }
  getter status_int : Int32 { map_status(status_str) }

  def map_status(status : String)
    case status
    when "暂停", "暂 停", "暂　停"
      2
    when "完成", "完本", "已经完结", "已经完本",
         "完结", "已完结", "此书已完成", "已完本", "全本",
         "完结申请", "已完成"
      1
    else
      0
    end
  end

  MISSING_UPDATE = {Time.utc(2020, 1, 1, 7, 0, 0), ""}

  getter update_str : String { @info.meta("og:novel:update_time") }
  getter update_int : Int64 { updated_at.to_unix }

  def updated_at(fix : Bool = false)
    time = TimeUtil.parse_time(update_str)
    return time unless fix

    time += 24.hours
    now = Time.utc - 1.minutes
    time < now ? time : now
  end

  def extract_schid(href : String)
    File.basename(href, ".html")
  end

  def last_schid : String
    extract_schid(last_schid_href)
  end

  def last_schid_href : String
    @info.meta("og:novel:latest_chapter_url")
  end

  def chapters : Array(ChInfo)
    extract_chapters_chvol("#list > dl")
  end

  def clean_chvol(chvol : String)
    chvol.gsub(/《.*》/, "").gsub(/\n|\t|\s{3,}/, "  ").strip
  end

  def extract_chapters_chvol(selector : String)
    chaps = [] of ChInfo
    return chaps unless body = @mulu.find(selector)

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

    @mulu.css(selector).each do |link|
      href = link.attributes["href"]
      chap = ChInfo.new(chaps.size + 1, extract_schid(href), link.inner_text)
      chaps << chap unless chap.invalid?
    rescue err
      puts err.colorize.red
    end

    chaps
  end
end

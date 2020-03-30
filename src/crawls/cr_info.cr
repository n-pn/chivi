require "time"
require "json"
require "colorize"

require "myhtml"

require "./cr_util"
require "../engine/cutil"

class CrInfo
  class Chap
    include JSON::Serializable

    property _id : String = "0"
    property title : String = ""
    property volume : String = "正文"

    def initialize(@_id, title, @volume = "正文")
      @title = title.sub(/^\d+\.\s*第/, "第").tr("　 ", " ").strip
      # TODO: Extract volume from title
    end

    def to_s(io : IO)
      io << to_pretty_json
    end
  end

  alias ChList = Array(Chap)

  # class ChList < Array(Chap)
  # end

  class Volume
    property label
    property chaps : ChList

    def initialize(@label = "正文", @chaps = ChList.new)
    end

    INDEX_RE = /([零〇一二三四五六七八九十百千]+)[集卷]/

    def index
      if match = INDEX_RE.match(@label)
        CUtil.hanzi_int(match[1])
      else
        0
      end
    end
  end

  class Serial
    include JSON::Serializable

    property _id : String = "0"
    property title : String = ""
    property author : String = ""
    property intro : String = ""

    property cover : String = ""
    property genre : String = ""
    property tags : Array(String) = [] of String

    property status : Int32 = 0

    property word_count : Int32 = 0
    property chap_count : Int32 = 0
    property updated_at : Int64 = 0

    def initialize(@_id, @updated_at = 0_i64)
    end

    def slug
      "#{@title}--#{@author}"
    end

    def to_s(io : IO)
      io << to_pretty_json
    end

    def status=(status : String)
      case status
      when "完成", "完本", "已经完结", "已经完本", "完结"
        @status = 1
      else
        @status = 0
      end
    end

    TITLES = Set(String).new File.read_lines("data/txt-tmp/yousuu/titles.txt")

    def title=(title : String)
      if TITLES.includes?(title)
        @title = title
      else
        @title = title.sub(/\(.+\)$/, "")
      end
    end

    def author=(author : String)
      @author = author.sub(/\(.+\)$/, "").sub(/\t.*$/, "")
    end

    def genre=(genre : String)
      @genre = genre.sub("小说", "")
    end

    def updated_at=(time : String)
      @updated_at = parse_time(time)
    end

    LOCATION = Time::Location.fixed(3600 * 8)
    FORMATER = {"%F %T", "%F %R", "%F", "%-m/%-d/%Y %r", "%-m/%-d/%Y %T", "%Y/%-m/%-d %T"}

    def parse_time(input : String)
      FORMATER.each do |format|
        return Time.parse(input, format, LOCATION).to_unix_ms
      rescue
        next
      end

      puts "Error parsing [#{input}]: unknown time format!".colorize(:red)
      Time.local(2010, 1, 1).to_unix_ms
    end
  end

  getter html : String = ""
  getter serial : Serial
  getter chlist : ChList

  getter html_file : String
  getter serial_file : String
  getter chlist_file : String

  def initialize(@site : String, @bsid : String, mtime = 0_i64)
    @html_file = "data/txt-inp/#{@site}/infos/#{@bsid}.html"
    @serial_file = "data/txt-tmp/serials/#{@site}/#{@bsid}.json"
    @chlist_file = "data/txt-tmp/chlists/#{@site}/#{@bsid}.json"

    @serial = Serial.new(@bsid, mtime)
    @chlist = ChList.new
  end

  def cached?(time : Time = Time.utc - 30.minutes, require_html = false)
    return false if CrUtil.outdated?(@serial_file, time)
    return false if CrUtil.outdated?(@chlist_file, time)
    !(require_html && CrUtil.outdated?(@html_file, time))
  end

  def load_cached!(serial = true, chlist = true)
    @serial = Serial.from_json(File.read(@serial_file)) if serial
    @chlist = ChList.from_json(File.read(@chlist_file)) if chlist
  end

  def reset_cache(html = true, serial = false, chlist = false)
    File.delete(@html_file) if File.exists?(@html_file) && html
    File.delete(@serial_file) if File.exists?(@serial_file) && serial
    File.delete(@chlist_file) if File.exists?(@chlist_file) && chlist
  end

  def crawl!(persist : Bool = true, label : String = "1/1") : Void
    if File.exists?(@html_file)
      @html = File.read(@html_file)
    else
      url = CrUtil.info_url(@site, @bsid)
      @html = CrUtil.fetch_html(url, @site)
      File.write(@html_file, @html) if persist
    end

    doc = Myhtml::Parser.new(@html)

    extract_serial!(doc)
    extract_chlist!(doc)
    @serial.chap_count = @chlist.size

    if persist
      File.write @serial_file, @serial.to_pretty_json
      File.write @chlist_file, @chlist.to_pretty_json

      puts "- <#{label.colorize(:yellow)}> \
              [#{@site.colorize(:yellow)}/#{@bsid.colorize(:yellow)}] \
              {#{@serial.title.colorize(:yellow)}} \
              saved!"
    end
  rescue err
    if err.class == Enumerable::EmptyError
      File.write @serial_file, @serial.to_pretty_json
      File.write @chlist_file, @chlist.to_pretty_json
    end
  end

  def extract_serial!(doc) : Void
    case @site
    when "jx_la", "duokan8", "nofff", "rengshu", "xbiquge", "paoshu8"
      doc.css("meta[property]").each do |node|
        prop = node.attributes["property"]
        text = node.attributes["content"]
        case prop
        when "og:novel:book_name"
          @serial.title = text
        when "og:novel:author"
          @serial.author = text
        when "og:description"
          @serial.intro = text
        when "og:image"
          @serial.cover = text
        when "og:novel:category"
          @serial.genre = text
        when "og:novel:status"
          @serial.status = text
        when "og:novel:update_time"
          @serial.updated_at = text
        end
      end
    when "hetushu"
      @serial.title = inner_text(doc, ".book_info > h2")
      @serial.author = inner_text(doc, ".book_info a:first-child")
      @serial.intro = doc.css(".intro > p").map(&.inner_text).join("\n")
      @serial.genre = inner_text(doc, ".book_info > div:nth-of-type(2)").sub("类型：", "").strip
      @serial.tags = doc.css(".tag a").map(&.inner_text).to_a
      if img = doc.css(".book_info img").first?
        @serial.cover = "https://www.hetushu.com/" + img.attributes["src"].as(String)
      end
    when "69shu"
      @serial.title = inner_text(doc, ".weizhi > a:nth-child(3)")
      @serial.author = inner_text(doc, ".mu_beizhu a[target]")
      @serial.genre = inner_text(doc, ".weizhi > a:nth-child(2)")
      @serial.updated_at = inner_text(doc, ".mu_beizhu").sub(/.+时间：/m, "")
    when "zhwenpg"
      info = doc.css(".cbooksingle").to_a[2]

      @serial.title = inner_text(info, "h2")
      @serial.author = inner_text(info, "h2 + a > font")
      @serial.intro = inner_text(info, "tr:nth-of-type(3)")
      @serial.cover = "https://novel.zhwenpg.com/image/cover/#{@bsid}.jpg"
    else
      raise "Site not supported!"
    end
  end

  def inner_text(doc, query)
    doc.css(query).first.inner_text.strip
  end

  def extract_chlist!(doc) : Void
    case @site
    when "duokan8"
      doc.css(".chapter-list a").each do |link|
        href = link.attributes["href"]
        csid = File.basename(href, ".html")
        text = link.inner_text
        @chlist << Chap.new(csid, text)
      end
    when "69shu"
      volumes = [] of ChList

      doc.css(".mu_contain").each do |node|
        volume = ChList.new

        node.css("a").each do |link|
          href = link.attributes["href"].not_nil!
          text = link.inner_text
          next if text.starts_with?("我要报错！")

          volume << Chap.new(File.basename(href), text)
        end

        volumes << volume
      end

      volumes.shift if volumes.size > 1
      @chlist = volumes.flatten
    when "zhwenpg"
      latest = inner_text(doc, ".fontchap")
      doc.css("#dulist a").each do |link|
        href = link.attributes["href"].not_nil!
        csid = href.sub("r.php?id=", "")
        @chlist << Chap.new(csid, link.inner_text)
      end

      @chlist.reverse! if latest.includes?(@chlist[0].title)
    when "jx_la", "nofff", "rengshu", "xbiquge", "paoshu8"
      @chlist = extract_chlist_by_volumes(doc, "#list dl")
    when "hetushu"
      @chlist = extract_chlist_by_volumes(doc, "#dir")
    else
      raise "Site not supported!"
    end
  end

  def extract_chlist_by_volumes(doc, query) : ChList
    volumes = [] of Volume
    caption = "《" + @serial.title + "》" # to be removed from volume name

    nodes = doc.css(query).first.children
    nodes.each do |node|
      if node.tag_sym == :dt
        label = node.inner_text.sub(caption, "").sub("《》", "").strip
        volumes << Volume.new(label)
      elsif node.tag_sym == :dd
        link = node.css("a").first?
        next unless link

        if href = link.attributes["href"]?
          csid = File.basename(href, ".html")
          title = link.inner_text

          volumes << Volume.new if volumes.empty?
          volumes.last.chaps << Chap.new(csid, title, volumes.last.label)
        end
      end
    end

    volumes.shift if volumes.first.label.includes?("最新章节")

    if @site == "jx_la"
      order = 0
      volumes.sort_by! do |volume|
        index = volume.index
        order += 1 if index == 0
        {order, index}
      end
    end

    volumes.map(&.chaps).flatten
  end
end

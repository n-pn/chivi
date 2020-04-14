require "myhtml"
require "file_utils"

require "../entity/sbook"
require "../entity/schap"
require "../engine/cutil"

require "./crawl_util"

class InfoCrawler
  class Volume
    property label
    property chaps : SList

    def initialize(@label = "正文", @chaps = SList.new)
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

  getter html : String = ""
  getter sbook : SBook
  getter slist : SList

  getter html_file : String
  getter sbook_file : String
  getter slist_file : String

  def initialize(@site : String, @bsid : String, mtime = 0_i64)
    @html_file = "data/txt-inp/#{@site}/infos/#{@bsid}.html"

    @sbook_file = SBook.file_path(@site, @bsid)
    @slist_file = SList.file_path(@site, @bsid)

    @sbook = SBook.new(@site, @bsid, mtime)
    @slist = SList.new
  end

  def mkdirs!
    FileUtils.mkdir_p(File.dirname(@html_file))
    FileUtils.mkdir_p(File.dirname(@sbook_file))
    FileUtils.mkdir_p(File.dirname(@slist_file))
  end

  def cached?(time = 30.minutes, require_html = false)
    return false if CrawlUtil.outdated?(@sbook_file, time)
    return false if CrawlUtil.outdated?(@slist_file, time)
    !(require_html && CrawlUtil.outdated?(@html_file, time))
  end

  def load_cached!(sbook = true, slist = true)
    @sbook = SBook.load(@sbook_file) if sbook
    @slist = SList.load(@slist_file) if slist
  end

  def reset_cache(html = true, sbook = false, chap = false)
    File.delete(@html_file) if File.exists?(@html_file) && html
    File.delete(@sbook_file) if File.exists?(@sbook_file) && book
    File.delete(@slist_file) if File.exists?(@slist_file) && chap
  end

  INFO_URLS = {
    "69shu"   => "https://www.69shu.com/%s/",
    "nofff"   => "https://www.nofff.com/%s",
    "jx_la"   => "https://www.jx.la/book/%s/",
    "rengshu" => "http://www.rengshu.com/book/%s",
    "xbiquge" => "https://www.xbiquge.cc/book/%s/",
    "hetushu" => "https://www.hetushu.com/book/%s/index.html",
    "duokan8" => "http://www.duokan8.com/%i_%i/",
    "paoshu8" => "http://www.paoshu8.com/%i_%i/",
    "zhwenpg" => "https://novel.zhwenpg.com/b.php?id=%s",
  }

  def info_url
    url_form = INFO_URLS[@site]
    if @site == "duokan8" || @site == "paoshu8"
      group_id = (@bsid.to_i // 1000).to_s
      url_form % [group_id, @bsid]
    else
      url_form % @bsid
    end
  end

  UTF_8 = {"jx_la", "hetushu", "paoshu8", "zhwenpg"}

  def crawl!(persist : Bool = true, label : String = "1/1") : Void
    if File.exists?(@html_file)
      @html = File.read(@html_file)
    else
      @html = CrawlUtil.fetch_html(info_url, @site)
      File.write(@html_file, @html) if persist
    end

    doc = Myhtml::Parser.new(@html)

    parse_sbook!(doc)
    parse_clist!(doc)
    @sbook.chaps = @slist.size

    if persist
      @sbook.save!(@sbook_file)
      @slist.save!(@slist_file)

      puts "- <#{label.colorize(:yellow)}> \
              [#{@site.colorize(:yellow)}/#{@bsid.colorize(:yellow)}] \
              {#{@sbook.title.colorize(:yellow)}} \
              saved!"
    end
  rescue err
    if err.class == Enumerable::EmptyError
      @sbook.save!(@sbook_file)
      @slist.save!(@slist_file)
    end
  end

  def parse_sbook!(doc = Myhtml::Parser.new(@html)) : Void
    case @site
    when "jx_la", "duokan8", "nofff", "rengshu", "xbiquge", "paoshu8"
      doc.css("meta[property]").each do |node|
        prop = node.attributes["property"]
        text = node.attributes["content"]

        case prop
        when "og:novel:book_name"
          @sbook.title = text
        when "og:novel:author"
          @sbook.author = text
        when "og:description"
          @sbook.intro = text
        when "og:image"
          @sbook.cover = text
        when "og:novel:category"
          @sbook.genre = text
        when "og:novel:status"
          @sbook.status = text
        when "og:novel:update_time"
          @sbook.mtime = text
        else
          next
        end
      end
    when "hetushu"
      @sbook.title = node_text(doc, ".book_info > h2")
      @sbook.author = node_text(doc, ".book_info a:first-child")
      @sbook.intro = doc.css(".intro > p").map(&.inner_text).join("\n")
      @sbook.genre = node_text(doc, ".book_info > div:nth-of-type(2)").sub("类型：", "").strip
      @sbook.tags = doc.css(".tag a").map(&.inner_text).to_a
      if img = doc.css(".book_info img").first?
        @sbook.cover = "https://www.hetushu.com/" + img.attributes["src"].as(String)
      end
    when "69shu"
      @sbook.title = node_text(doc, ".weizhi > a:nth-child(3)")
      @sbook.author = node_text(doc, ".mu_beizhu a[target]")
      @sbook.genre = node_text(doc, ".weizhi > a:nth-child(2)")
      @sbook.mtime = node_text(doc, ".mu_beizhu").sub(/.+时间：/m, "")
    when "zhwenpg"
      node = doc.css(".cbooksingle").to_a[2]

      @sbook.title = node_text(node, "h2")
      @sbook.author = node_text(node, "h2 + a > font")
      @sbook.intro = node_text(node, "tr:nth-of-type(3)")
      @sbook.cover = "https://novel.zhwenpg.com/image/cover/#{@bsid}.jpg"
    else
      raise "Site not supported!"
    end
  end

  def node_text(doc, query)
    doc.css(query).first.inner_text.strip
  end

  def parse_clist!(doc) : Void
    case @site
    when "duokan8"
      doc.css(".chapter-list a").each do |link|
        if href = link.attributes["href"]?
          @slist << SChap.new(File.basename(href, ".html"), link.inner_text)
        end
      end
    when "69shu"
      lists = [] of SList

      doc.css(".mu_contain").each do |node|
        list = SList.new

        node.css("a").each do |link|
          if href = link.attributes["href"]?
            title = link.inner_text
            next if title.starts_with?("我要报错！")
            list << SChap.new(File.basename(href), title)
          end
        end

        lists << list
      end

      lists.shift if lists.size > 1
      lists.each do |list|
        list.each { |x| @slist << x }
      end
    when "zhwenpg"
      latest = node_text(doc, ".fontchap")

      doc.css("#dulist a").each do |link|
        if href = link.attributes["href"]
          @slist << SChap.new(href.sub("r.php?id=", ""), link.inner_text)
        end
      end

      @slist.reverse! if latest.includes?(@slist[0].title)
    when "jx_la", "nofff", "rengshu", "xbiquge", "paoshu8"
      @slist = extract_clist_by_volumes(doc, "#list dl")
    when "hetushu"
      @slist = extract_clist_by_volumes(doc, "#dir")
    else
      raise "Site not supported!"
    end
  end

  def extract_clist_by_volumes(doc, query) : SList
    volumes = [] of Volume
    caption = "《" + @sbook.title + "》" # to be removed from volume name

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
          volumes.last.chaps << SChap.new(csid, title, volumes.last.label)
        end
      end
    end

    volumes.shift if volumes.first.label.includes?("最新章节")

    if @site == "jx_la"
      order = 0

      volumes.sort_by! do |volume|
        if volume.label == "作品相关"
          {-1, 0}
        else
          index = volume.index
          order += 1 if index == 0
          {order, index}
        end
      end
    end

    list = SList.new
    volumes.each { |x| list.concat(x.chaps) }
    list
  end
end

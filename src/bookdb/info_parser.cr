require "../utils/hanzi_int"
require "../utils/parse_time"

require "../models/zh_info"
require "../models/zh_chap"

require "./parse_util"

alias ZhList = Array(ZhChap)

class Volume
  property label
  property chaps : ZhList

  def initialize(@label = "正文", @chaps = [] of ZhChap)
  end

  INDEX_RE = /([零〇一二两三四五六七八九十百千]+|\d+)[集卷]/

  def index
    if match = INDEX_RE.match(@label)
      Utils.hanzi_int(match[1])
    else
      0
    end
  end
end

class InfoParser
  SITE_URLS = {
    "nofff"   => "https://www.nofff.com/%s",
    "69shu"   => "https://www.69shu.com/%s/",
    "jx_la"   => "https://www.jx.la/book/%s/",
    "rengshu" => "http://www.rengshu.com/book/%s",
    "xbiquge" => "https://www.xbiquge.cc/book/%s/",
    "hetushu" => "https://www.hetushu.com/book/%s/index.html",
    "duokan8" => "http://www.duokan8.com/%i_%i/",
    "paoshu8" => "http://www.paoshu8.com/%i_%i/",
    "zhwenpg" => "https://novel.zhwenpg.com/b.php?id=%s",
  }

  def self.site_url(site : String, bsid : String) : String
    url = SITE_URLS[site]
    if site == "duokan8" || site == "paoshu8"
      group_id = (bsid.to_i // 1000).to_s
      url % [group_id, bsid]
    else
      url % bsid
    end
  end

  HTML_DIR = "data/txt-inp"

  def self.html_dir(site : String)
    File.join(HTML_DIR, site, "infos")
  end

  def self.html_file(site : String, bsid : String)
    File.join(html_dir(site), "#{bsid}.html")
  end

  def self.load!(site : String, bsid : String, expiry = 10.hours, frozen = true)
    file = html_file(site, bsid)

    if ParseUtil.outdated?(file, expiry)
      url = site_url(site, bsid)
      html = ParseUtil.fetch_html(url)
      File.write(file, html) if frozen
    else
      html = File.read(file)
    end

    new(html, site)
  end

  # getter dom : Myhtml::Parser
  getter site : String
  getter zh_info : ZhInfo
  getter zh_list = ZhList.new

  def initialize(html : String, @site : String, @zh_info = ZhInfo.new)
    @dom = Myhtml::Parser.new(html)
  end

  def parse_info!
    parse_title! if @zh_info.title.empty?

    parse_author! if @zh_info.author.empty?
    parse_intro! if @zh_info.intro.empty?
    parse_cover! if @zh_info.cover.empty?
    parse_genre! if @zh_info.genre.empty?
    # @zh_info.genre = genre.sub("小说", "") if @zh_info.genre.empty?
    parse_tags! if @zh_info.tags.empty?
    parse_state! if @zh_info.state == 0
    parse_mtime! if @zh_info.mtime == 0

    @zh_info
  end

  def parse_title!
    case @site
    when "jx_la", "duokan8", "nofff", "rengshu", "xbiquge", "paoshu8"
      @zh_info.title = ParseUtil.meta_content(@dom, "og:novel:book_name")
    when "hetushu"
      @zh_info.title = ParseUtil.inner_text(@dom, "h2")
    when "69shu"
      @zh_info.title = ParseUtil.inner_text(@dom, ".weizhi > a:last-child")
    when "zhwenpg"
      @zh_info.title = ParseUtil.inner_text(@dom, ".cbooksingle h2")
    else
      raise "Site not supported!"
    end

    @zh_info.title
  end

  def parse_author!
    case @site
    when "jx_la", "duokan8", "nofff", "rengshu", "xbiquge", "paoshu8"
      @zh_info.author = ParseUtil.meta_content(@dom, "og:novel:author")
    when "hetushu"
      @zh_info.author = ParseUtil.inner_text(@dom, ".book_info a:first-child")
    when "69shu"
      @zh_info.author = ParseUtil.inner_text(@dom, ".mu_beizhu > a[target]")
    when "zhwenpg"
      @zh_info.author = ParseUtil.inner_text(@dom, ".fontwt")
    else
      raise "Site not supported!"
    end

    @zh_info.author
  end

  def parse_intro!
    case @site
    when "jx_la", "duokan8", "nofff", "rengshu", "xbiquge", "paoshu8"
      @zh_info.intro = ParseUtil.meta_content(@dom, "og:description")
    when "hetushu"
      @zh_info.intro = @dom.css(".intro > p").map(&.inner_text).join("\n")
    when "69shu"
      # TODO: extract 69shu book intro
    when "zhwenpg"
      @zh_info.intro = ParseUtil.inner_text(@dom, "tr:nth-of-type(3)")
    else
      raise "Site not supported!"
    end

    @zh_info.intro
  end

  def parse_cover!
    case @site
    when "jx_la", "duokan8", "nofff", "rengshu", "xbiquge", "paoshu8"
      cover = ParseUtil.meta_content(@dom, "og:image")
      cover = cover.sub("qu.la", "jx.la") if @site == "jx_la"

      @zh_info.cover = cover
    when "hetushu"
      if img_node = @dom.css(".book_info img").first?
        url = img_node.attributes["src"]
        @zh_info.cover = "https://www.hetushu.com#{url}"
      end
    when "69shu"
      # TODO: extract 69shu book cover
    when "zhwenpg"
      img_node = @dom.css(".cover_wrapper_m img").first
      @zh_info.cover = img_node.attributes["data-src"]
    else
      raise "Site not supported!"
    end

    @zh_info.cover
  end

  def parse_genre!
    case @site
    when "jx_la", "duokan8", "nofff", "rengshu", "xbiquge", "paoshu8"
      @zh_info.genre = ParseUtil.meta_content(@dom, "og:novel:category")
    when "hetushu"
      @zh_info.genre = ParseUtil.inner_text(@dom, ".title > a:nth-child(2)").strip
    when "69shu"
      @zh_info.genre = ParseUtil.inner_text(@dom, ".weizhi > a:nth-child(2)")
    when "zhwenpg"
      # pass
    else
      raise "Site not supported!"
    end

    @zh_info.genre
  end

  def parse_tags!
    if @site == "hetushu"
      @zh_info.tags = @dom.css(".tag a").map(&.inner_text).to_a
    end

    @zh_info.tags
  end

  def parse_state!
    case @site
    when "jx_la", "duokan8", "nofff", "rengshu", "xbiquge", "paoshu8"
      case ParseUtil.meta_content(@dom, "og:novel:status")
      when "完成", "完本", "已经完结", "已经完本", "完结"
        @zh_info.state = 1
      else
        # pass
      end
    when "hetushu"
      info_node = @dom.css(".book_info").first
      if info_node.attributes["class"].includes?("finish")
        @zh_info.state = 1
      end
    when "zhwenpg", "69shu"
      # pass
    else
      raise "Site not supported!"
    end

    @zh_info.state
  end

  def parse_mtime!(mtime = 0_i64)
    case @site
    when "jx_la", "duokan8", "nofff", "rengshu", "xbiquge", "paoshu8"
      text = ParseUtil.meta_content(@dom, "og:novel:update_time")
      @zh_info.mtime = Utils.parse_time(text)
    when "hetushu"
      @zh_info.mtime = mtime
    when "69shu"
      mtime = ParseUtil.inner_text(@dom, ".mu_beizhu").sub(/.+时间：/m, "")
      @zh_info.mtime = Utils.parse_time(mtime)
    when "zhwenpg"
      @zh_info.mtime = mtime
    else
      raise "Site not supported!"
    end

    @zh_info.mtime
  end

  def parse_list!
    case @site
    when "duokan8"
      @dom.css(".chapter-list a").each do |link|
        if href = link.attributes["href"]?
          csid = File.basename(href, ".html")
          title = link.inner_text

          @zh_list << ZhChap.new(csid, title)
        end
      end
    when "69shu"
      volumes = @dom.css(".mu_contain").to_a.map do |node|
        volume = Volume.new

        node.css("a").each do |link|
          if href = link.attributes["href"]?
            csid = File.basename(href)
            title = link.inner_text
            next if title.starts_with?("我要报错！")

            volume.chaps << ZhChap.new(csid, title)
          end
        end

        volume
      end

      volumes.shift if volumes.size > 1
      volumes.each { |volume| @zh_list.concat(volume.chaps) }
    when "zhwenpg"
      latest_chap = ParseUtil.inner_text(@dom, ".fontchap")
      latest_title, _ = Utils.split_title(latest_chap)

      @dom.css("#dulist a").each do |link|
        if href = link.attributes["href"]?
          csid = href.sub("r.php?id=", "")
          @zh_list << ZhChap.new(csid, link.inner_text)
        end
      end

      @zh_list.reverse! if latest_title == @zh_list.first.title
    when "jx_la", "nofff", "rengshu", "xbiquge", "paoshu8"
      @zh_list = extract_volumes("#list dl", @zh_list)
    when "hetushu"
      @zh_list = extract_volumes("#dir", @zh_list)
    else
      raise "Site not supported!"
    end

    @zh_list
  end

  private def extract_volumes(selector, output = ZhList.new)
    volumes = [] of Volume

    nodes = @dom.css(selector).first.children

    nodes.each do |node|
      if node.tag_sym == :dt
        label = node.inner_text.gsub(/《.*》/, "").strip
        volumes << Volume.new(label)
      elsif node.tag_sym == :dd
        link = node.css("a").first?
        next unless link

        if href = link.attributes["href"]?
          csid = File.basename(href, ".html")
          title = link.inner_text

          volumes << Volume.new if volumes.empty?
          volumes.last.chaps << ZhChap.new(csid, title, volumes.last.label)
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

    volumes.each { |volume| output.concat(volume.chaps) }

    output
  end
end

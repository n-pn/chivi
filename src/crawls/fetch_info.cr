require "myhtml"

require "./models/zh_info"
require "./models/zh_chap"

require "./utils/html_utils"
require "./utils/file_utils"
require "./utils/parse_time"
require "./utils/hanzi_int"

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
  def self.load(site : String, bsid : String, expiry = 10.hours, frozen = true)
    load(ZhInfo.new(site, bsid), expiry, frozen)
  end

  def self.load(info : ZhInfo, expiry = 10.hours, frozen = true)
    url = Utils.info_url(info.site, info.bsid)
    file = Utils.info_path(info.site, info.bsid)

    unless html = Utils.read_file(file, expiry)
      html = Utils.fetch_html(url)
      File.write(file, html) if frozen
    end

    new(info, html)
  end

  # getter dom : Myhtml::Parser
  getter info : ZhInfo
  getter list = ZhList.new

  def initialize(@info, html : String)
    @dom = Myhtml::Parser.new(html)
    @list = ZhList.new
  end

  def get_infos!
    get_title! if @info.title.empty?
    get_author! if @info.author.empty?
    get_intro! if @info.intro.empty?
    get_cover! if @info.cover.empty?
    get_genre! if @info.genre.empty?
    get_tags! if @info.tags.empty?
    get_state! if @info.state == 0
    get_mtime! if @info.mtime == 0

    @info
  end

  def get_title!
    case @info.site
    when "jx_la", "duokan8", "nofff", "rengshu", "xbiquge", "paoshu8"
      @info.title = meta_content("og:novel:book_name")
    when "hetushu"
      @info.title = inner_text("h2")
    when "69shu"
      @info.title = inner_text(".weizhi > a:last-child")
    when "zhwenpg"
      @info.title = inner_text(".cbooksingle h2")
    else
      raise "Site not supported!"
    end

    @info.title
  end

  def get_author!
    case @info.site
    when "jx_la", "duokan8", "nofff", "rengshu", "xbiquge", "paoshu8"
      @info.author = meta_content("og:novel:author")
    when "hetushu"
      @info.author = inner_text(".book_info a:first-child")
    when "69shu"
      @info.author = inner_text(".mu_beizhu > a[target]")
    when "zhwenpg"
      @info.author = inner_text(".fontwt")
    else
      raise "Site not supported!"
    end

    @info.author
  end

  def get_intro!
    case @info.site
    when "jx_la", "duokan8", "nofff", "rengshu", "xbiquge", "paoshu8"
      @info.intro = meta_content("og:description")
    when "hetushu"
      @info.intro = @dom.css(".intro > p").map(&.inner_text).join("\n")
    when "69shu"
      # TODO: extract 69shu book intro
    when "zhwenpg"
      @info.intro = inner_text("tr:nth-of-type(3)")
    else
      raise "Site not supported!"
    end

    @info.intro
  end

  def get_cover!
    case @info.site
    when "jx_la", "duokan8", "nofff", "rengshu", "xbiquge", "paoshu8"
      cover = meta_content("og:image")
      cover = cover.sub("qu.la", "jx.la") if @info.site == "jx_la"

      @info.cover = cover
    when "hetushu"
      if img_node = @dom.css(".book_info img").first?
        url = img_node.attributes["src"]
        @info.cover = "https://www.hetushu.com#{url}"
      end
    when "69shu"
      # TODO: extract 69shu book cover
    when "zhwenpg"
      img_node = @dom.css(".cover_wrapper_m img").first
      @info.cover = img_node.attributes["data-src"]
    else
      raise "Site not supported!"
    end

    @info.cover
  end

  def get_genre!
    case @info.site
    when "jx_la", "duokan8", "nofff", "rengshu", "xbiquge", "paoshu8"
      @info.genre = meta_content("og:novel:category")
    when "hetushu"
      @info.genre = inner_text(".title > a:nth-child(2)").strip
    when "69shu"
      @info.genre = inner_text(".weizhi > a:nth-child(2)")
    when "zhwenpg"
      # pass
    else
      raise "Site not supported!"
    end
  end

  def get_tags!
    if @info.site == "hetushu"
      @info.tags = @dom.css(".tag a").map(&.inner_text).to_a
    end

    @info.tags
  end

  def get_state!
    case @info.site
    when "jx_la", "duokan8", "nofff", "rengshu", "xbiquge", "paoshu8"
      case meta_content("og:novel:status")
      when "完成", "完本", "已经完结", "已经完本", "完结"
        @info.state = 1
      else
        # pass
      end
    when "hetushu"
      info_node = @dom.css(".book_info").first
      if info_node.attributes["class"].includes?("finish")
        @info.state = 1
      end
    when "zhwenpg", "69shu"
      # pass
    else
      raise "Site not supported!"
    end

    @info.state
  end

  def get_mtime!(mtime = 0_i64)
    case @info.site
    when "jx_la", "duokan8", "nofff", "rengshu", "xbiquge", "paoshu8"
      text = meta_content("og:novel:update_time")
      @info.mtime = Utils.parse_time(text)
    when "hetushu"
      @info.mtime = mtime
    when "69shu"
      mtime = inner_text(".mu_beizhu").sub(/.+时间：/m, "")
      @info.mtime = Utils.parse_time(mtime)
    when "zhwenpg"
      @info.mtime = mtime
    else
      raise "Site not supported!"
    end

    @info.mtime
  end

  def get_chaps!
    case @info.site
    when "duokan8"
      @dom.css(".chapter-list a").each do |link|
        if href = link.attributes["href"]?
          csid = File.basename(href, ".html")
          title = link.inner_text

          @list << ZhChap.new(csid, title)
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
      volumes.each { |volume| @list.concat(volume.chaps) }
    when "zhwenpg"
      latest_chap = inner_text(".fontchap")
      latest_title, _ = Utils.split_title(latest_chap)

      @dom.css("#dulist a").each do |link|
        if href = link.attributes["href"]?
          csid = href.sub("r.php?id=", "")
          @list << ZhChap.new(csid, link.inner_text)
        end
      end

      @list.reverse! if latest_title == @list.first.title
    when "jx_la", "nofff", "rengshu", "xbiquge", "paoshu8"
      @list = extract_volumes("#list dl", @list)
    when "hetushu"
      @list = extract_volumes("#dir", @list)
    else
      raise "Site not supported!"
    end

    @list
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

    if @info.site == "jx_la"
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

  private def inner_text(css : String)
    @dom.css(css).first.inner_text.strip
  end

  private def meta_content(css : String)
    node = @dom.css("meta[property=\"#{css}\"]").first
    node.attributes["content"]
  end
end

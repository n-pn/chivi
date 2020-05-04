require "json"
require "myhtml"

require "../engine/cv_util"
require "./spider_util"

class SpChap
  include JSON::Serializable

  property csid : String = "0"
  property title : String = ""
  property volume : String = "正文"

  def initialize(@csid, title, volume = "")
    if volume.empty?
      @title, @volume = SpiderUtil.split_title(title)
    else
      @title = SpiderUtil.fix_title(title)
      @volume = SpiderUtil.clean_title(volume)
    end
  end

  def to_s(io : IO)
    io << to_pretty_json
  end
end

alias SpList = Array(SpChap)

class Volume
  property label
  property chaps : SpList

  def initialize(@label = "正文", @chaps = SpList.new)
  end

  INDEX_RE = /([零〇一二两三四五六七八九十百千]+|\d+)[集卷]/

  def index
    if match = INDEX_RE.match(@label)
      CvUtil.hanzi_int(match[1])
    else
      0
    end
  end
end

class InfoSpider
  def self.load(site : String, bsid : String, expiry = 10.hours, frozen = true)
    url = SpiderUtil.info_url(site, bsid)
    file = SpiderUtil.info_path(site, bsid)

    unless html = SpiderUtil.read_file(file, expiry)
      html = SpiderUtil.fetch_html(url)
      File.write(file, html) if frozen
    end

    new(html, site, bsid)
  end

  def initialize(html : String, @site : String, @bsid : String)
    @dom = Myhtml::Parser.new(html)
  end

  def get_infos!
    {
      title:  get_title!,
      author: get_author!,
      intro:  get_intro!,
      cover:  get_cover!,
      genre:  get_genre!,
      tags:   get_tags!,
      status: get_status!,
      update: get_update!,
    }
  end

  def get_title!
    case @site
    when "jx_la", "duokan8", "nofff", "rengshu", "xbiquge", "paoshu8"
      meta_content("og:novel:book_name")
    when "hetushu"
      inner_text("h2")
    when "69shu"
      inner_text(".weizhi > a:last-child")
    when "zhwenpg"
      inner_text(".cbooksingle h2")
    else
      raise "Site not supported!"
    end
  end

  def get_author!
    case @site
    when "jx_la", "duokan8", "nofff", "rengshu", "xbiquge", "paoshu8"
      meta_content("og:novel:author")
    when "hetushu"
      inner_text(".book_info a:first-child")
    when "69shu"
      inner_text(".mu_beizhu > a[target]")
    when "zhwenpg"
      inner_text(".fontwt")
    else
      raise "Site not supported!"
    end
  end

  def get_intro!
    case @site
    when "jx_la", "duokan8", "nofff", "rengshu", "xbiquge", "paoshu8"
      meta_content("og:description")
    when "hetushu"
      @dom.css(".intro > p").map(&.inner_text).join("\n")
    when "69shu"
      # TODO: extract 69shu book intro
    when "zhwenpg"
      inner_text("tr:nth-of-type(3)")
    else
      raise "Site not supported!"
    end
  end

  def get_cover!
    case @site
    when "jx_la", "duokan8", "nofff", "rengshu", "xbiquge", "paoshu8"
      cover = meta_content("og:image")
      cover = cover.sub("qu.la", "jx.la") if @site == "jx_la"
      cover
    when "hetushu"
      if img_node = @dom.css(".book_info img").first?
        url = img_node.attributes["src"]
        "https://www.hetushu.com#{url}"
      else
        ""
      end
    when "69shu"
      # TODO: extract 69shu book cover
      ""
    when "zhwenpg"
      img_node = @dom.css(".cover_wrapper_m img").first
      img_node.attributes["data-src"] || ""
    else
      raise "Site not supported!"
    end
  end

  def get_genre!
    case @site
    when "jx_la", "duokan8", "nofff", "rengshu", "xbiquge", "paoshu8"
      meta_content("og:novel:category")
    when "hetushu"
      inner_text(".title > a:nth-child(2)").strip
    when "69shu"
      inner_text(".weizhi > a:nth-child(2)")
    when "zhwenpg"
      ""
    else
      raise "Site not supported!"
    end
  end

  def get_tags!
    if @site == "hetushu"
      @dom.css(".tag a").map(&.inner_text).to_a
    else
      [] of String
    end
  end

  def get_status!
    case @site
    when "jx_la", "duokan8", "nofff", "rengshu", "xbiquge", "paoshu8"
      case meta_content("og:novel:status")
      when "完成", "完本", "已经完结", "已经完本", "完结"
        1
      else
        0
      end
    when "hetushu"
      info_node = @dom.css(".book_info").first
      if info_node.attributes["class"].includes?("finish")
        1
      else
        0
      end
    when "zhwenpg", "69shu"
      0
    else
      raise "Site not supported!"
    end
  end

  def get_update!
    case @site
    when "jx_la", "duokan8", "nofff", "rengshu", "xbiquge", "paoshu8"
      text = meta_content("og:novel:update_time")
      SpiderUtil.parse_time(text)
    when "hetushu"
      0_i64
    when "69shu"
      text = inner_text(".mu_beizhu").sub(/.+时间：/m, "")
      SpiderUtil.parse_time(text)
    when "zhwenpg"
      0_i64
    else
      raise "Site not supported!"
    end
  end

  def get_chaps!
    output = SpList.new

    case @site
    when "duokan8"
      @dom.css(".chapter-list a").each do |link|
        if href = link.attributes["href"]?
          csid = File.basename(href, ".html")
          title = link.inner_text

          output << SpChap.new(csid, title)
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

            volume.chaps << SpChap.new(csid, title)
          end
        end

        volume
      end

      volumes.shift if volumes.size > 1
      volumes.each { |volume| output.concat(volume.chaps) }
    when "zhwenpg"
      latest_chap = inner_text(".fontchap")
      latest_title, _ = SpiderUtil.split_title(latest_chap)

      @dom.css("#dulist a").each do |link|
        if href = link.attributes["href"]?
          csid = href.sub("r.php?id=", "")
          output << SpChap.new(csid, link.inner_text)
        end
      end

      output.reverse! if latest_title == output.first.title
    when "jx_la", "nofff", "rengshu", "xbiquge", "paoshu8"
      output = extract_volumes("#list dl")
    when "hetushu"
      output = extract_volumes("#dir")
    else
      raise "Site not supported!"
    end

    output
  end

  private def extract_volumes(selector)
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
          volumes.last.chaps << SpChap.new(csid, title, volumes.last.label)
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

    output = SpList.new
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

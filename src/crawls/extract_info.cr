require "../engine/cv_util"
require "../utils/parse_time"

require "../models/zh_info"
require "../models/zh_chap"

require "./leech_util"

alias ZhList = Array(ZhChap)

class Volume
  property label
  property chaps : ZhList

  def initialize(@label = "正文", @chaps = [] of ZhChap)
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

module ExtractInfo
  extend self

  HTML_DIR = "data/txt-inp"

  def load_dom(site : String, bsid : String, expiry = 10.hours, frozen = true)
    file = File.join(HTML_DIR, site, "infos", "#{bsid}.html")

    if LeechUtil.outdated?(file, expiry)
      url = site_url(site, bsid)
      html = LeechUtil.fetch_html(url)
      File.write(file, html) if frozen
    else
      html = File.read(file)
    end

    Myhtml::Parser.new(html)
  end

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

  def site_url(site : String, bsid : String) : String
    url = SITE_URLS[site]
    if site == "duokan8" || site == "paoshu8"
      group_id = (bsid.to_i // 1000).to_s
      url % [group_id, bsid]
    else
      url % bsid
    end
  end

  def extract_info!(dom : Myhtml::Parser, site : String, output = ZhInfo.new)
    case site
    when "jx_la", "duokan8", "nofff", "rengshu", "xbiquge", "paoshu8"
      dom.css("meta[property]").each do |node|
        prop = node.attributes["property"]
        text = node.attributes["content"]

        case prop
        when "og:novel:book_name"
          output.title = text
        when "og:novel:author"
          output.author = text
        when "og:description"
          output.intro = text
        when "og:image"
          text = text.sub("qu.la", "jx.la") if site == "jx_la"
          output.cover = text
        when "og:novel:category"
          output.genre = text
        when "og:novel:status"
          case text
          when "完成", "完本", "已经完结", "已经完本", "完结"
            output.state = 1
          else
            output.state = 0
          end
        when "og:novel:update_time"
          output.mtime = Utils.parse_time(text)
        else
          next
        end
      end
    when "hetushu"
      info_node = dom.css(".book_info").first

      output.title = LeechUtil.dom_text(info_node, "h2")
      output.author = LeechUtil.dom_text(info_node, "a:first-child")

      output.intro = dom.css(".intro > p").map(&.inner_text).join("\n")
      output.genre = LeechUtil.dom_text(info_node, "div:nth-of-type(2)").sub("类型：", "").strip
      output.tags = dom.css(".tag a").map(&.inner_text).to_a

      if img_node = info_node.css("img").first?
        url = img_node.attributes["src"]?
        output.cover = "https://www.hetushu.com/#{url}"
      end

      output.state = 1 if info_node.attributes["class"].includes?("finish")
    when "69shu"
      output.title = LeechUtil.dom_text(dom, ".weizhi > a:nth-child(3)")
      output.author = LeechUtil.dom_text(dom, ".mu_beizhu a[target]")
      output.genre = LeechUtil.dom_text(dom, ".weizhi > a:nth-child(2)")

      mtime = LeechUtil.dom_text(dom, ".mu_beizhu").sub(/.+时间：/m, "")
      output.mtime = Utils.parse_time(mtime)
    when "zhwenpg"
      node = dom.css(".cbooksingle").to_a[2]

      output.title = LeechUtil.dom_text(node, "h2")
      output.author = LeechUtil.dom_text(node, "h2 + a > font")
      output.intro = LeechUtil.dom_text(node, "tr:nth-of-type(3)")
      if img_node = dom.css(".cover_wrapper_m img").first?
        output.cover = img_node.attributes["data-src"]
      end
    else
      raise "Site not supported!"
    end

    output.genre = output.genre.sub("小说", "")

    output
  end

  def extract_list!(dom : Myhtml::Parser, site : String, output = ZhList.new)
    case site
    when "duokan8"
      dom.css(".chapter-list a").each do |link|
        if href = link.attributes["href"]?
          csid = File.basename(href, ".html")
          title = link.inner_text

          output << ZhChap.new(csid, title)
        end
      end
    when "69shu"
      volumes = dom.css(".mu_contain").to_a.map do |node|
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
      volumes.each { |volume| output.concat(volume.chaps) }
    when "zhwenpg"
      latest_chap = LeechUtil.dom_text(dom, ".fontchap")
      latest_title, _ = Utils.split_title(latest_chap)

      dom.css("#dulist a").each do |link|
        if href = link.attributes["href"]?
          csid = href.sub("r.php?id=", "")
          output << ZhChap.new(csid, link.inner_text)
        end
      end

      output.reverse! if latest_title == output.first.title
    when "jx_la", "nofff", "rengshu", "xbiquge", "paoshu8"
      output = extract_volumes(dom, "#list dl", site, output)
    when "hetushu"
      output = extract_volumes(dom, "#dir", site, output)
    else
      raise "Site not supported!"
    end

    output
  end

  private def extract_volumes(dom, selector, site, output = ZhList.new)
    volumes = [] of Volume

    nodes = dom.css(selector).first.children

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

    if site == "jx_la"
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

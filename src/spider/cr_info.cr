require "../engine/cv_util"

require "../kernel/serial/zh_info"
require "../kernel/serial/zh_stat"
require "../kernel/chlist/zh_list"

require "./cr_core"

class Spider::CrInfo
  HTML_DIR = "data/txt-inp"

  def initialize(@site : String, @bsid : String, cache = true, span = 10.hours)
    file = File.join(HTML_DIR, @site, "infos", "#{@bsid}.html")

    if CrCore.outdated?(file, span)
      html = CrCore.fetch_html(site_url)
      File.write(file, html) if cache
    else
      html = File.read(file)
    end

    @dom = Myhtml::Parser.new(html)
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

  def site_url : String
    url = SITE_URLS[@site]
    if @site == "duokan8" || @site == "paoshu8"
      group_id = (@bsid.to_i // 1000).to_s
      url % [group_id, @bsid]
    else
      url % @bsid
    end
  end

  def extract_info!
    output = Serial::ZhInfo.new
    output.crawl_links[@site] = @bsid

    case @site
    when "jx_la", "duokan8", "nofff", "rengshu", "xbiquge", "paoshu8"
      @dom.css("meta[property]").each do |node|
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
          text = text.sub("qu.la", "jx.la") if @site == "jx_la"
          output.cover = text
        when "og:novel:category"
          output.genre = text
        else
          next
        end
      end
    when "hetushu"
      output.title = CrCore.dom_text(@dom, ".book_info > h2")
      output.author = CrCore.dom_text(@dom, ".book_info a:first-child")
      output.intro = @dom.css(".intro > p").map(&.inner_text).join("\n")
      output.genre = CrCore.dom_text(@dom, ".book_info > div:nth-of-type(2)").sub("类型：", "").strip
      output.tags = @dom.css(".tag a").map(&.inner_text).to_a
      if img = @dom.css(".book_info img").first?
        output.cover = "https://www.hetushu.com/" + img.attributes["src"].as(String)
      end
    when "69shu"
      output.title = CrCore.dom_text(@dom, ".weizhi > a:nth-child(3)")
      output.author = CrCore.dom_text(@dom, ".mu_beizhu a[target]")
      output.genre = CrCore.dom_text(@dom, ".weizhi > a:nth-child(2)")
    when "zhwenpg"
      node = @dom.css(".cbooksingle").to_a[2]

      output.title = CrCore.dom_text(node, "h2")
      output.author = CrCore.dom_text(node, "h2 + a > font")
      output.intro = CrCore.dom_text(node, "tr:nth-of-type(3)")
      output.cover = "https://novel.zhwenpg.com/image/cover/#{@bsid}.jpg"
    else
      raise "Site not supported!"
    end

    output.genre = output.genre.sub("小说", "")

    output
  end

  def extract_stat!(mtime = 0_i64)
    output = Serial::ZhStat.new
    output.mtime = mtime

    case @site
    when "jx_la", "duokan8", "nofff", "rengshu", "xbiquge", "paoshu8"
      @dom.css("meta[property]").each do |node|
        prop = node.attributes["property"]
        text = node.attributes["content"]

        case prop
        when "og:novel:status"
          case text
          when "完成", "完本", "已经完结", "已经完本", "完结"
            output.status = 1
          else
            output.status = 0
          end
        when "og:novel:update_time"
          output.mtime = Serial::ZhStat.parse_time(text)
        else
          next
        end
      end
    when "hetushu"
      info = @dom.css(".book_info").first
      if klass = info.attributes["class"]?
        output.status = klass.includes?("finish") ? 1 : 0
      end
      # pass
    when "69shu"
      time = CrCore.dom_text(@dom, ".mu_beizhu").sub(/.+时间：/m, "")
      output.mtime = Serial::ZhStat.parse_time(time)
      output.mtime = mtime if output.mtime < mtime
    when "zhwenpg"
      # pass
    else
      raise "Site not supported!"
    end

    output
  end

  def extract_list!
    output = Chlist::ZhList.new(@site, @bsid)

    case @site
    when "duokan8"
      @dom.css(".chapter-list a").each do |link|
        if href = link.attributes["href"]?
          csid = File.basename(href, ".html")
          title = link.inner_text

          output << Chlist::ZhChap.new(csid, title)
        end
      end
    when "69shu"
      volumes = @dom.css(".mu_contain").to_a.map do |node|
        volume = Chlist::Volume.new

        node.css("a").each do |link|
          if href = link.attributes["href"]?
            csid = File.basename(href)
            title = link.inner_text
            next if title.starts_with?("我要报错！")

            volume.chaps << Chlist::ZhChap.new(csid, title)
          end
        end

        volume
      end

      volumes.shift if volumes.size > 1
      volumes.each { |volume| output.concat(volume.chaps) }
    when "zhwenpg"
      latest = CrCore.dom_text(@dom, ".fontchap")

      @dom.css("#dulist a").each do |link|
        if href = link.attributes["href"]?
          csid = href.sub("r.php?id=", "")
          output << Chlist::ZhChap.new(csid, link.inner_text)
        end
      end

      output.list.reverse! if latest.includes?(output.first.title)
    when "jx_la", "nofff", "rengshu", "xbiquge", "paoshu8"
      extract_volumes(output, "#list dl")
    when "hetushu"
      extract_volumes(output, "#dir")
    else
      raise "Site not supported!"
    end

    output
  end

  private def extract_volumes(output, selector) : Chlist::ZhList
    volumes = [] of Chlist::Volume

    nodes = @dom.css(selector).first.children

    nodes.each do |node|
      if node.tag_sym == :dt
        label = node.inner_text.gsub(/《.*》/, "").strip
        volumes << Chlist::Volume.new(label)
      elsif node.tag_sym == :dd
        link = node.css("a").first?
        next unless link

        if href = link.attributes["href"]?
          csid = File.basename(href, ".html")
          title = link.inner_text

          volumes << Chlist::Volume.new if volumes.empty?
          volumes.last.chaps << Chlist::ZhChap.new(csid, title, volumes.last.label)
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
          index = Engine::CvUtil.hanzi_int(volume.index)
          order += 1 if index == 0
          {order, index}
        end
      end
    end

    volumes.each { |volume| output.concat(volume.chaps) }

    output
  end
end

require "../engine/cv_util"

require "../models/zh_info"
require "../models/zh_stat"

module Spider::CrList
  def crawl!(site : String, bsid : String, span = 3.hours, save = true)
    html = CrUtil.info_html(site, bsid, span)
    doc = Myhtml::Parser.new(html)
  end

  def parse!(dom : Myhtml::Parser, site : String)
    output = Chlist.new

    case site
    when "duokan8"
      dom.css(".chapter-list a").each do |link|
        if href = link.attributes["href"]?
          csid = File.basename(href, ".html")
          title = link.inner_text

          output << Chinfo.new(csid, title)
        end
      end
    when "69shu"
      volumes = [] of Chlist

      dom.css(".mu_contain").each do |node|
        volume = Chlist.new

        node.css("a").each do |link|
          if href = link.attributes["href"]?
            csid = File.basename(href)
            title = link.inner_text
            next if title.starts_with?("我要报错！")

            volume << Chinfo.new(bsid, title)
          end
        end

        volumes << volume
      end

      volumes.shift if volumes.size > 1
      volumes.each do |volume|
        volume.each { |x| output << x }
      end
    when "zhwenpg"
      latest = CrUtil.dom_text(dom, ".fontchap")

      dom.css("#dulist a").each do |link|
        if href = link.attributes["href"]?
          csid = href.sub("r.php?id=", "")
          output << Chinfo.new(csid, link.inner_text)
        end
      end

      output.reverse! if latest.includes?(output.first.title)
    when "jx_la", "nofff", "rengshu", "xbiquge", "paoshu8"
      output = extract_volumes(dom, "#list dl")
    when "hetushu"
      output = extract_volumes(dom, "#dir")
    else
      raise "Site not supported!"
    end

    output
  end

  private def extract_volumes(dom, selector) : Chlist
    volumes = [] of Volume
    caption = "《" + @serial.title + "》" # to be removed from volume name

    nodes = dom.css(selector).first.children

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
          volumes.last.chaps << Chinfo.new(csid, title, volumes.last.label)
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
          index = Engine::CvUtil.hanzi_int(volume.index)
          order += 1 if index == 0
          {order, index}
        end
      end
    end

    list = Chlist.new
    volumes.each { |x| list.concat(x.chaps) }
    list
  end

  extend self
end

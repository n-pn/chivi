require "myhtml"
require "colorize"

require "./spider_util"

module SourceText
  extend self

  DIR = File.join("data", ".inits", "books")

  def root(site : String, bsid : String)
    File.join(DIR, site, bsid)
  end

  def text_url(site : String, bsid : String, csid : String)
    case site
    when "nofff"
      "https://www.nofff.com/#{bsid}/#{csid}/"
    when "69shu"
      "https://www.69shu.com/txt/#{bsid}/#{csid}"
    when "jx_la"
      "https://www.jx.la/book/#{bsid}/#{csid}.html"
    when "rengshu"
      "http://www.rengshu.com/book/#{bsid}/#{csid}"
    when "xbiquge"
      "https://www.xbiquge.cc/book/#{bsid}/#{csid}.html"
    when "hetushu"
      "https://www.hetushu.com/book/#{bsid}/#{csid}.html"
    when "duokan8"
      block = bsid.to_i // 1000
      "http://www.duokan8.com/#{block}_#{bsid}/#{csid}.html"
    when "paoshu8"
      block = bsid.to_i // 1000
      "http://www.paoshu8.com/#{block}_#{bsid}/#{csid}.html"
    when "zhwenpg"
      "https://novel.zhwenpg.com/r.php?id=#{csid}"
    else
      raise "- source site `#{site}` is unsupported!"
    end
  end

  def fetch!(site : String, bsid : String, csid : String, save_html : Bool = true)
    url = text_url(site, bsid, csid)
    file = File.join(root(site, bsid), "#{csid}.html")

    if File.exists?(file)
      html = Utils.read_file(file)
    else
      html = SpiderUtil.fetch_html(url)
      File.write(file, html) if save_html
    end

    dom = Myhtml::Parser.new(html)

    lines = [extract_title!(dom, site)]
    lines.concat(extract_paras!(dom, site))

    lines.map(&.tr(" 　", " ").strip).reject(&.empty?)
  end

  def extract_title!(dom : Myhtml::Parser, site : String)
    case site
    when "jx_la", "nofff", "rengshu", "paoshu8", "xbiquge", "69shu"
      extract_text(dom, "h1")
    when "zhwenpg"
      extract_text(dom, "h2")
    when "hetushu"
      dom.css("#content .h2").first.inner_text
    when "duokan8"
      extract_text(@dom, "#read-content > h2").sub(/^章节目录\s*/, "")
    else
      raise "- source site `#{site}` unsupported!"
    end
  end

  def extract_paras!(dom : Myhtml::Parser, site : String)
    case site
    when "hetushu"
      parse_hetushu_paras!(dom)
    when "jx_la", "nofff", "rengshu", "paoshu8"
      extract_body(dom, "#content")
    when "zhwenpg"
      extract_body(dom, "#tdcontent .content")
    when "69shu"
      paras = extract_body(dom, ".yd_text2")
      paras[-1] = paras[1].sub("(本章完)", "")
      paras
    when "xbiquge"
      paras = extract_body(dom, "#content")
      paras.map(&.gsub("www.xbiquge.cc", "").gsub("【】", ""))
    when "duokan8"
      paras = extract_body("#htmlContent > p")

      if first = paras[0]?
        paras[0] = first.sub(/.+<\/h1>/, "")
      end

      paras.map(&.sub("</div>", ""))
    else
      raise "Site #{@site} unsupported!"
    end
  end

  private def parse_hetushu_paras!(dom : Myhtml::Parser)
    lines = dom.css("#content div:not([class])").map(&.inner_text(deep: false)).to_a
    paras = Array(String).new(lines.size)

    meta = dom.css("meta[name=client]").first.attributes["content"]
    jump = 0

    Base64.decode_string(meta).split(/[A-Z]+%/).map_with_index do |pos, idx|
      pos = pos.to_i

      if pos < 5
        jump += 1
      else
        pos -= jump
      end

      paras[pos] = lines[idx]
    end

    paras
  end

  def extract_text(dom, selector : String)
    return "" unless node = dom.css(selector).first?
    node.inner_text
  end

  def extract_body(dom, selector : String, ignores : Array(String) = ["script", "div"])
    return [""] unless node = dom.css(selector).first?
    node.children.each { |x| x.remove! if ignores.includes?(x.x_name) }
    node.inner_text("\n").split("\n")
  end
end

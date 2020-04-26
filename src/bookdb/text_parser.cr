require "time"
require "json"
require "colorize"
require "file_utils"

require "myhtml"

require "./parse_util"

class TextParser
  def self.text_path(site : String, bsid : String, csid : String) : String
    File.join(DIR, site, "texts", bsid, "#{csid}.html")
  end

  TEXT_URLS = {
    "nofff"   => "https://www.nofff.com/%s/%s/",
    "69shu"   => "https://www.69shu.com/txt/%s/%s",
    "jx_la"   => "https://www.jx.la/book/%s/%s.html",
    "rengshu" => "http://www.rengshu.com/book/%s/%s",
    "xbiquge" => "https://www.xbiquge.cc/book/%s/%s.html",
    "hetushu" => "https://www.hetushu.com/book/%s/%s.html",
    "duokan8" => "http://www.duokan8.com/%i_%i/%s.html",
    "paoshu8" => "http://www.paoshu8.com/%i_%i/%s.html",
    "zhwenpg" => "https://novel.zhwenpg.com/r.php?id=%s",
  }

  def self.text_url(site : String, bsid : String, csid : String) : String
    url = TEXT_URLS[site]
    case site
    when "zhwenpg"
      url % csid
    when "duokan8", "paoshu8"
      group = (bsid.to_i // 1000).to_s
      url % [group, bsid, csid]
    else
      url % [bsid, csid]
    end
  end

  HTML_DIR = "data/txt-inp"

  def self.html_dir(site : String, bsid : String)
    File.join(HTML_DIR, site, "texts", bsid)
  end

  def self.html_file(site : String, bsid : String, csid : String)
    File.join(html_dir(site, bsid), "#{csid}.html")
  end

  def self.load_dom(site : String, bsid : String, csid : String, expiry = 10.hours, frozen = true)
    file = html_file(site, bsid, csid)

    if ParseUtil.outdated?(file, expiry)
      url = text_url(site, bsid, csid)
      html = ParseUtil.fetch_html(url)
      File.write(file, html) if frozen
    else
      html = File.read(file)
    end

    new(html, site)
  end

  getter title : String
  getter paras : Array(String)

  def initialize(@site : String, @title = "")
    @paras = [] of String
  end

  def mkdir!
    FileUtils.mkdir_p File.join(@@dir, @site, @bsid)
  end

  def cached?(require_html : Bool = false)
    return false unless File.exists?(@file)
    !(require_html && !File.exists?(HtmlCrawler.text_path(@site, @bsid, @csid)))
  end

  def crawl!(persist : Bool = true, label = "1/1") : Void
    html = HtmlCrawler.fetch_text(@site, @bsid, @csid)
    parse!(Myhtml::Parser.new(html))

    if persist
      puts "-- <#{label.colorize(:cyan)}> \
      [#{@site.colorize(:cyan)}/#{@bsid.colorize(:cyan)}/#{@csid.colorize(:cyan)}] \
      {#{@title.colorize(:cyan)}} saved."

      File.write(@file, self)
    end
  end

  def parse!(doc) : Void
    case @site
    when "jx_la", "nofff", "rengshu", "paoshu8"
      @title = extract_text(doc, "h1") || @title
      @paras = extract_body(doc, "#content")
    when "xbiquge"
      @title = extract_text(doc, "h1") || @title
      @paras = extract_body(doc, "#content")
      @paras.reject!(&.includes?("www.xbiquge.cc"))
    when "69shu"
      @title = extract_text(doc, "h1") || @title
      @paras = extract_body(doc, ".yd_text2")
    when "hetushu"
      @title = doc.css("#content .h2").first.inner_text

      lines = doc.css("#content div:not([class])").map(&.inner_text(deep: false)).to_a
      @paras = Array(String).new(lines.size, "")

      meta = doc.css("meta[name=client]").first.attributes["content"].as(String)
      jdx = 0
      Base64.decode_string(meta).split(/[A-Z]+%/).map_with_index do |ord, idx|
        ord = ord.to_i
        if ord < 5
          jdx += 1
        else
          ord -= jdx
        end
        @paras[ord] = lines[idx]
      end

      # @paras = lines
    when "zhwenpg"
      @title = extract_text(doc, "h2") || @title
      @paras = extract_body(doc, "#tdcontent .content")
    when "duokan8"
      @title = extract_text(doc, "#read-content > h2") || @title
      @title = @title.sub(/^章节目录\s*/, "")
      @paras = extract_body(doc, "#htmlContent > p").map(&.sub("</div>", ""))
      if first = @paras[0]?
        @paras[0] = first.sub(/.+<\/h1>/, "")
      end
    else
      raise "Site #{@site} unsupported!"
    end

    @title = @title.sub(/^\d+\.\s*第/, "第") # for 69shu

    if (first = @paras[0]?) && @title =~ /\P{Han}/
      @title.split(" ").each do |tt|
        break unless first.starts_with?(tt)
        first = first.sub(/^#{tt}/, "").lstrip
      end

      @paras[0] = first
    end

    if last = @paras[-1]?
      @paras[-1] = last.sub("(本章完)", "")
    end

    @paras = @paras.map(&.gsub("【】", "").strip).reject(&.empty?)
  end

  def to_s(io)
    io << @title
    paras.each do |line|
      io << "\n" << line
    end
  end

  def extract_text(doc, query)
    if tag = doc.css(query).first?
      tag.inner_text.tr(" 　", " ").strip
    end
  end

  def extract_body(doc, query, dels = ["script", "div"])
    node = doc.css(query).first
    node.children.each do |tag|
      tag.remove! if dels.includes?(tag.tag_name)
    end

    node.inner_text("\n").tr(" 　", " ").split("\n")
  end
end

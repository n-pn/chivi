require "time"
require "json"
require "colorize"
require "file_utils"

require "myhtml"

require "./cr_html"

class LeechText
  getter file : String

  getter title : String
  getter paras : Array(String)

  @@dir = File.join("data", "txt-tmp", "chtexts")

  def self.dir
    @@dir
  end

  def self.dir=(@@dir)
  end

  def self.file_path(site, bsid, csid)
    File.join(dir, site, bsid, "#{csid}.txt")
  end

  def initialize(@site : String, @bsid : String, @csid : String, @title : String = "")
    @file = CrText.file_path(site, bsid, csid)
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

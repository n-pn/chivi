require "time"
require "json"
require "colorize"
require "file_utils"

require "myhtml"
require "./cr_util"

class CrText
  getter html : String = ""
  getter title : String
  getter paras : Array(String)

  getter html_file : String
  getter text_file : String

  def initialize(@site : String, @bsid : String, @csid : String, @title : String = "")
    @html_file = ".inp/#{@site}/texts/#{@bsid}/#{@csid}.html"
    @text_file = ".tmp/chtexts/#{@site}/#{@bsid}/#{@csid}.txt"

    @paras = [] of String
  end

  def cached?(require_html : Bool = false)
    return false unless File.exists?(@text_file)
    !(require_html && !File.exists?(@html_file))
  end

  def reset_cache(html : Bool = true, text : Bool = false)
    File.delete(@html_file) if File.exists?(@html_file) && html
    File.delete(@text_file) if File.exists?(@text_file) && text
  end

  def crawl!(persist : Bool = true, index = "0/0") : Void
    if File.exists?(@html_file)
      @html = File.read(@html_file)
    else
      url = CrUtil.text_url(@site, @bsid, @csid)
      @html = CrUtil.fetch_html(url, @site)
    end

    doc = Myhtml::Parser.new(@html)
    parse!(doc)

    if persist
      File.write(@html_file, html)

      puts "-- <#{index}.colorize(:cyan)> \
      [#{@site}/#{@bsid}/#{@csid}] \
      {#{@title.colorize(:cyan)}} saved."

      File.write(@text_file, self)
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
      @title = extract_text(doc, ".h2") || @title
      @paras = doc.css("#content > div").map do |node|
        node.inner_text(deep: false).tr(" 　", " ")
      end.to_a
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

require "time"
require "json"
require "colorize"
require "file_utils"

require "myhtml"
require "./cr_util"

module CrText
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

  def crawl!(persist : Bool = true, index = 0) : Void
    if File.exists?(@html_file)
      @html = File.read(@html_file)
    else
      url = CrUtil.text_url(@site, @bsid, @csid)
      @html = CrUtil.fetch_text(text_url, encoding)
    end

    doc = Myhtml::Parser.new(@html)
    parse!(doc)

    if persist
      File.write(@html_file, html)
      puts "-- <#{index}> [#{@site}/#{@bsid}/#{@csid}] {#{@title}} saved.".colorize(:cyan)
      File.write(@text_file, self)
      File.utime(@mtime, @mtime, @text_file)
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
        Util.clean_text(node.inner_text(deep: false))
      end.to_a
    when "zhwenpg"
      @title = extract_text(doc, "h2") || @title
      @paras = doc.css("#tdcontent p").map { |x| clean_text(x.inner_text) }.to_a.reject(&.empty?)
    when "duokan8"
      @title = extract_text(doc, "#read-content > h2") || @title
      @title = @title.sub(/^章节目录\s*/, "")
      @paras = extract_body(doc, "#htmlContent")
      @paras = @paras.map(&.sub("</div>", "").sub("</h1>", "")).reject(&.empty?)
    else
      raise "Site #{@site} unsupported!"
    end

    @title = @title.sub(/^\d+\.\s*第/, "第") # for 69shu

    if (first = @paras[0]?) && @title =~ /\P{Han}/
      @title.split(" ").each do |tt|
        break unless first.starts_with?(tt)
        first = first.sub(/^#{tt}/, "").lstrip
      end

      if first.empty?
        @paras.shift
      else
        @paras[0] = first
      end
    end

    if last = @paras[-1]?
      last = last.sub("(本章完)", "").strip
      if last.empty?
        @paras.pop
      else
        @paras[-1] = last
      end
    end
  end

  def to_s(io)
    io << @title
    paras.each do |line|
      io << "\n" << line
    end
  end

  def extract_text(doc, query)
    if tag = doc.css(query).first?
      clean_text(tag.inner_text)
    end
  end

  def clean_text(input)
    input.tr(" 　", " ").strip
  end

  def extract_body(doc, query = "#content", dels = ["script", "div"])
    if node = doc.css(query).first?
      dels.each { |x| node.css(x).each(&.remove!) }
      # node.css("br").each { |x| x.data = "\n" }
      Util.split_clean(node.inner_text("\n"))
    else
      raise "No text!!!"
    end
  end
end

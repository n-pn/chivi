require "colorize"

require "myhtml"

require "./utils/file_utils"
require "./utils/html_utils"
require "./utils/fix_info"

class TextParser
  def self.load(site : String, bsid : String, csid : String, expiry = 10.hours, frozen = true)
    url = Utils.text_url(site, bsid, csid)
    file = Utils.text_path(site, bsid, csid)

    unless html = Utils.read_file(file, expiry)
      html = Utils.fetch_html(url)
      File.write(file, html) if frozen
    end

    new(html, site)
  end

  getter title : String
  getter paras : Array(String)

  def initialize(html : String, @site : String, @title = "")
    @dom = Myhtml::Parser.new(html)
    @paras = [] of String
  end

  def get_title!
    if title = parse_title!
      @title, _ = Utils.split_title(title)
    end

    @title
  end

  def parse_title!
    case @site
    when "jx_la", "nofff", "rengshu", "paoshu8"
      extract_text("h1")
    when "xbiquge"
      extract_text("h1")
    when "69shu"
      extract_text("h1")
    when "hetushu"
      @dom.css("#content .h2").first.inner_text
    when "zhwenpg"
      extract_text("h2")
    when "duokan8"
      text = extract_text("#read-content > h2") || ""
      text.sub(/^章节目录\s*/, "")
    else
      raise "Site #{@site} unsupported!"
    end
  end

  def get_paras!
    case @site
    when "jx_la", "nofff", "rengshu", "paoshu8"
      @paras = extract_body("#content")
    when "xbiquge"
      @paras = extract_body("#content")
      @paras.reject!(&.includes?("www.xbiquge.cc"))
    when "69shu"
      @paras = extract_body(".yd_text2")
    when "hetushu"
      lines = @dom.css("#content div:not([class])").map(&.inner_text(deep: false)).to_a
      @paras = Array(String).new(lines.size, "")

      meta = @dom.css("meta[name=client]").first.attributes["content"].as(String)
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
      @paras = extract_body("#tdcontent .content")
    when "duokan8"
      @paras = extract_body("#htmlContent > p").map(&.sub("</div>", ""))
      if first = @paras[0]?
        @paras[0] = first.sub(/.+<\/h1>/, "")
      end
    else
      raise "Site #{@site} unsupported!"
    end

    clean_paras_by_title!

    if last = @paras[-1]?
      @paras[-1] = last.sub("(本章完)", "")
    end

    @paras = @paras.map(&.gsub("【】", "").strip).reject(&.empty?)

    @paras
  end

  def clean_paras_by_title!
    if first = @paras[0]?
      return unless @title =~ /\P{Han}/
      @title.split(" ").each do |frag|
        return unless first.starts_with?(frag)
        first = first.sub(/^#{frag}/, "").lstrip
      end

      if first.empty?
        @paras.delete_at(0)
      else
        @paras[0] = first
      end
    end
  end

  def to_s(io)
    io << @title
    paras.each do |line|
      io << "\n" << line
    end
  end

  def extract_text(query)
    if tag = @dom.css(query).first?
      tag.inner_text.tr(" 　", " ").strip
    end
  end

  def extract_body(query, dels = ["script", "div"])
    node = @dom.css(query).first
    node.children.each { |tag| tag.remove! if dels.includes?(tag.tag_name) }

    node.inner_text("\n").tr(" 　", " ").split("\n")
  end
end

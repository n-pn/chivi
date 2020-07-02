require "myhtml"
require "colorize"
require "file_utils"

require "../utils/file_utils"
require "../utils/html_utils"
require "../utils/text_utils"

class RemoteText
  DIR = File.join("var", "appcv", ".cache")
  FileUtils.mkdir_p(DIR)

  def initialize(@seed : String, @sbid : String)
    @root = File.join(DIR, @seed, "texts", @sbid)
    FileUtils.mkdir_p(@root)
  end

  def text_url(scid : String)
    case @seed
    when "nofff"
      "https://www.nofff.com/#{@sbid}/#{scid}/"
    when "69shu"
      "https://www.69shu.com/txt/#{@sbid}/#{scid}"
    when "jx_la"
      "https://www.jx.la/book/#{@sbid}/#{scid}.html"
    when "rengshu"
      "http://www.rengshu.com/book/#{@sbid}/#{scid}"
    when "xbiquge"
      "https://www.xbiquge.cc/book/#{@sbid}/#{scid}.html"
    when "hetushu"
      "https://www.hetushu.com/book/#{@sbid}/#{scid}.html"
    when "duokan8"
      group = @sbid.to_i // 1000
      "http://www.duokan8.com/#{group}_#{@sbid}/#{scid}.html"
    when "paoshu8"
      group = @sbid.to_i // 1000
      "http://www.paoshu8.com/#{group}_#{@sbid}/#{scid}.html"
    when "zhwenpg"
      "https://novel.zhwenpg.com/r.php?id=#{scid}"
    else
      raise "- seed `#{@seed}` not supported!"
    end
  end

  def text_path(scid : String)
    File.join(@root, "#{scid}.html")
  end

  def fetch_text!(scid : String, keep_html : Bool = false)
    html = fetch_html!(scid, persist: keep_html)
    extract_html!(html)
  end

  def fetch_html!(scid : String, persist : Bool = true)
    file = text_path(scid)

    unless html = Utils.read_file(file)
      html = Utils.fetch_html(text_url(scid))
      File.write(file, html) if persist
    end

    html
  end

  def extract_html!(html : String) : String
    dom = Myhtml::Parser.new(html)

    String.build do |io|
      title = extract_title!(dom)
      io << title

      lines = extract_body!(dom)
      lines.shift if title.includes?(lines[0])

      lines.each do |line|
        io << "\n" << line
      end
    end
  end

  def extract_title!(dom : Myhtml::Parser)
    case @seed
    when "jx_la", "nofff", "rengshu", "paoshu8", "xbiquge", "69shu"
      parse_title!(dom, "h1")
    when "zhwenpg"
      parse_title!(dom, "h2")
    when "hetushu"
      dom.css("#content .h2").first.inner_text
    when "duokan8"
      parse_title!(dom, "#read-content > h2").sub(/^章节目录\s*/, "")
    else
      raise "- seed `#{@seed}` not supported!"
    end
  end

  def parse_title!(dom : Myhtml::Parser, query : String)
    return "" unless node = dom.css(query).first?
    Utils.clean_text(node.inner_text)
  end

  def extract_body!(dom : Myhtml::Parser)
    case @seed
    when "jx_la", "nofff", "rengshu", "paoshu8", "xbiquge"
      parse_body!(dom, "#content")
    when "zhwenpg"
      parse_body!(dom, "#tdcontent .content")
    when "duokan8"
      parse_body!(dom, "#htmlContent > p")
    when "69shu"
      parse_body!(dom, ".yd_text2")
    when "hetushu"
      parse_body_hetushu!(dom)
    else
      raise "- seed `#{@seed}` not supported!"
    end
  end

  def parse_body!(dom : Myhtml::Parser, query : String)
    return [] of String unless node = dom.css(query).first?
    node.children.each do |tag|
      tag.remove! if {"script", "div"}.includes?(tag.tag_name)
    end

    lines = node.inner_text("\n").split("\n")

    if @seed == "duokan8"
      lines.update(0, &.sub(/.+<\/h1>\s*/, ""))
      lines.map!(&.sub("</div>", ""))
    elsif @seed == "xbiquge"
      lines.map!(&.sub("www.xbiquge.cc", ""))
    end

    lines.update(-1, &.sub("(本章完)", ""))
    lines.map! { |line| Utils.clean_text(line) }.reject!(&.empty?)
  end

  def parse_body_hetushu!(dom : Myhtml::Parser)
    client = dom.css("meta[name=client]").first.attributes["content"]
    orders = Base64.decode_string(client).split(/[A-Z]+%/)

    res = Array(String).new(orders.size, "")
    jmp = 0

    inp = dom.css("#content div:not([class])").map_with_index do |node, idx|
      ord = orders[idx].to_i

      if ord < 5
        jmp += 1
      else
        ord -= jmp
      end

      res[ord] = node.inner_text(deep: false)
    end

    res
  end
end

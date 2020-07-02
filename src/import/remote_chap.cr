require "../utils/file_utils"
require "../utils/html_utils"
require "../utils/text_utils"

require "./remote_util"

class RemoteText
  def self.fetch!(seed : String, sbid : String, scid : String, freeze = false)
    new(seed, fetch_html!(seed, sbid, scid, freeze))
  end

  def self.fetch_html!(seed : String, sbid : String, scid : String, freeze = true)
    path = RemoteUtil.text_path(seed, sbid, scid)

    unless html = Utils.read_file(path)
      html = Utils.fetch_html(RemoteUtil.text_url(seed, sbid, scid))
      File.write(path, html) if freeze
    end

    html
  end

  getter title : String
  getter paras : Array(String)

  def initialize(@seed : String, html : String)
    @doc = Myhtml::Parser.new(html)
    @title = parse_title!
    @paras = parse_paras!
  end

  def to_s(io : IO)
    io << title
    paras.each { |para| io << "\n" << para }
  end

  def to_s
    String.build { |io| to_s(io) }
  end

  def save!(path : String) : Void
    File.write(path, self)
    puts "- <remote_text> saved to file [#{path}]."
  end

  def parse_title!
    case @seed
    when "jx_la", "nofff", "rengshu", "paoshu8", "xbiquge", "69shu"
      inner_text("h1")
    when "zhwenpg"
      inner_text("h2")
    when "hetushu"
      inner_text("#content .h2")
    when "duokan8"
      inner_text("#read-content > h2").sub(/^章节目录\s*/, "")
    else
      raise "- unknown seed."
    end
  end

  private def inner_text(query : String)
    return "" unless node = @doc.css(query).first?
    Utils.clean_text(node.inner_text)
  end

  def paras
    @paras ||= parse_paras!
  end

  def parse_paras!
    case @seed
    when "jx_la", "nofff", "rengshu", "paoshu8", "xbiquge"
      parse_paras!("#content")
    when "zhwenpg"
      parse_paras!("#tdcontent .content")
    when "duokan8"
      parse_paras!("#htmlContent > p")
    when "69shu"
      parse_paras!(".yd_text2")
    when "hetushu"
      parse_hetushu_paras!
    else
      raise "- seed `#{@seed}` not supported!"
    end
  end

  private def parse_paras!(selector : String)
    return [] of String unless node = @doc.css(selector).first?
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

    lines.shift if @title.includes?(lines[0])
    lines.update(-1, &.sub("(本章完)", ""))

    lines.map! { |line| Utils.clean_text(line) }.reject!(&.empty?)
  end

  private def parse_hetushu_paras!
    client = @doc.css("meta[name=client]").first.attributes["content"]
    orders = Base64.decode_string(client).split(/[A-Z]+%/)

    res = Array(String).new(orders.size, "")
    jmp = 0

    inp = @doc.css("#content div:not([class])").map_with_index do |node, idx|
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

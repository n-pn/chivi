require "myhtml"
require "colorize"
require "file_utils"

require "../../utils/file_util"
require "../../utils/http_util"
require "../../utils/text_util"

class SeedText
  DIR = File.join("var", "appcv", ".cached")
  FileUtils.mkdir_p(DIR)

  def self.mkdir!(seed : String, sbid : String)
    FileUtils.mkdir_p(root(seed, sbid))
  end

  def self.root(seed : String, sbid : String)
    File.join(DIR, seed, "texts", sbid)
  end

  def self.path_for(seed : String, sbid : String, scid : String)
    File.join(root(seed, sbid), "#{scid}.html")
  end

  def self.text_url(seed : String, sbid : String, scid : String)
    case seed
    when "zhwenpg"
      "https://novel.zhwenpg.com/r.php?id=#{scid}"
    when "nofff"
      "https://www.nofff.com/#{sbid}/#{scid}/"
    when "69shu"
      "https://www.69shu.com/txt/#{sbid}/#{scid}"
    when "qu_la"
      "https://www.qu.la/book/#{sbid}/#{scid}.html"
    when "jx_la"
      "https://www.jx.la/book/#{sbid}/#{scid}.html"
    when "rengshu"
      "http://www.rengshu.com/book/#{sbid}/#{scid}"
    when "xbiquge"
      "https://www.xbiquge.cc/book/#{sbid}/#{scid}.html"
    when "hetushu"
      "https://www.hetushu.com/book/#{sbid}/#{scid}.html"
    when "duokan8"
      group = sbid.to_i // 1000
      "http://www.duokan8.com/#{group}_#{sbid}/#{scid}.html"
    when "paoshu8"
      group = sbid.to_i // 1000
      "http://www.paoshu8.com/#{group}_#{sbid}/#{scid}.html"
    when "5200"
      group = sbid.to_i // 1000
      "https://www.5200.net/#{group}_#{sbid}/#{scid}.html"
    when "biquge5200"
      group = sbid.to_i // 1000
      "https://www.biquge5200/#{group}_#{sbid}/#{scid}.html"
    when "shubaow"
      group = sbid.to_i // 1000
      "https://www.shubaow.net/#{group}_#{sbid}/#{scid}.html"
    else
      raise "- seed `#{seed}` not supported!"
    end
  end

  def self.init(seed : String, sbid : String, scid : String, expiry = Time.utc(2010, 1, 1), freeze = false)
    url = text_url(seed, sbid, scid)
    file = path_for(seed, sbid, scid)
    FileUtils.mkdir_p(File.dirname(file))

    unless html = FileUtil.read(file, expiry)
      html = HttpUtil.fetch_html(url, HttpUtil.encoding_for(seed))
      File.write(file, html) if freeze
    end

    new(seed, html)
  end

  def initialize(@seed : String, html : String)
    @doc = Myhtml::Parser.new(html)
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

  getter title : String { parse_title! }
  getter paras : Array(String) { parse_paras! }

  def parse_title!
    case @seed
    when "jx_la", "nofff", "rengshu",
         "paoshu8", "xbiquge", "5200", "biquge5200",
         "shubaow"
      title_text("h1")
    when "qu_la"
      title_text(".title")
    when "zhwenpg"
      title_text("h2")
    when "hetushu"
      title_text("#content .h2")
    when "duokan8"
      title_text("#read-content > h2")
        .sub(/^章节目录\s*/, "")
        .sub(/《.+》正文\s/, "")
    when "69shu"
      title_text("h1").sub(/\d+\.第/, "第")
    else
      raise "- unknown seed."
    end
  end

  private def title_text(query : String)
    return "" unless node = @doc.css(query).first?
    clean_text(node.inner_text)
  end

  def parse_paras!
    case @seed
    when "qu_la", "jx_la", "nofff",
         "rengshu", "paoshu8", "xbiquge",
         "5200", "biquge5200", "shubaow"
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
    end

    lines.map! { |x| clean_text(x) }.reject!(&.empty?)
    lines.shift if lines.first == title

    case @seed
    when "xbiquge"
      lines.shift if lines.first.starts_with?("笔趣阁 ")
    when "jx_la"
      lines.pop if lines.last.starts_with?("正在手打中，")
    when "5200"
      lines.pop if lines.last.ends_with?("更新速度最快。")
    end

    lines.pop if lines.last == "(本章完)"

    lines
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

      res[ord] = node.inner_text(deep: false).strip
    end

    res
  end

  private def clean_text(input)
    input = TextUtil.clean_html(input)
    input = TextUtil.fix_spaces(input)
    input.strip
  end
end

# pp TextUtil.clean_html("    三位大儒默契的没有接，而是彼此交换眼神。").strip

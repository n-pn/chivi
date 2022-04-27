require "http/client"

require "../_util/site_link"
require "../_util/time_util"
require "../_util/text_util"
require "../_util/http_util"
require "./shared/html_parser"

class CV::RemoteText
  # cache folder path
  PATH = "var/chmetas/.html/%s/%s/%s.html.gz"

  getter sname : String
  getter snvid : String
  getter schid : String
  getter title : String

  @ttl : Time::Span | Time::MonthSpan

  getter file : String
  getter link : String

  def initialize(@sname, @snvid, @schid, @ttl = 10.years, @lbl = "-/-")
    @file = PATH % {@sname, @snvid, @schid}
    @link = SiteLink.text_url(sname, snvid, schid)

    @title = extract_title
  end

  getter page : HtmlParser do
    encoding = HttpUtil.encoding_for(@sname)

    Dir.mkdir_p(File.dirname(@file))
    html = HttpUtil.cache(@file, @link, @ttl, @lbl, encoding)
    HtmlParser.new(html)
  end

  def extract_title
    case @sname
    when "duokan8"
      extract_title("#read-content > h2")
        .sub(/^章节目录\s*/, "")
        .sub(/《.+》正文\s/, "")
    when "hetushu" then page.text("#content .h2")
    when "zhwenpg" then extract_title("h2")
    when "ptwxz"   then extract_title("h1").split(/\s+/, 4).last
    else                extract_title("h1")
    end
  end

  # remove volume label from chap title
  private def extract_title(sel : String) : String
    title = page.text(sel)
    TextUtil.format_title(title)[0]
  end

  getter paras : Array(String) do
    case @sname
    when "69shu"   then extract_69shu_paras
    when "hetushu" then extract_hetushu_paras
    when "biqugee" then extract_biqugee_paras
    when "zhwenpg" then extract_paras("#tdcontent .content")
    when "duokan8" then extract_paras("#htmlContent > p")
    when "ptwxz"   then extract_paras("body")
    else                extract_paras("#content")
    end
  end

  private def extract_69shu_paras
    unless node = page.find(".txtnav")
      return extract_paras(".yd_text2")
    end

    node.children.each do |tag|
      tag.remove! if {"script", "div", "h1", "table"}.includes?(tag.tag_name)
    end

    lines = TextUtil.split_html(node.inner_text("\n"))
    lines.shift if lines.first == title
    lines.pop if lines.last == "(本章完)"

    lines
  end

  def extract_biqugee_paras
    paras = extract_paras("#content")
    return paras unless paras.empty?
    extract_paras(".box_con")
  end

  # ameba:disable Metrics/CyclomaticComplexity
  private def extract_paras(sel : String)
    return [] of String unless node = page.find(sel)

    page.clean_node(node, :script, :div, :h1, :table)

    if @sname == "bxwxorg"
      node.children.each do |tag|
        tag.remove! if tag.attributes["style"]?
      end
    end

    lines = TextUtil.split_html(node.inner_text("\n"))
    return lines if lines.empty?
    lines.shift if lines.first == title

    case @sname
    when "zhwenpg"
      title.split(/\s+/).each { |x| lines[0] = lines[0].sub(/^#{x}\s*/, "") }
    when "jx_la"
      lines.pop if lines.last.starts_with?("正在手打中")
    when "5200"
      lines.pop if lines.last.ends_with?("更新速度最快。")
    when "sdyfcm"
      3.times { lines.shift } if lines[1].includes?("eqeq.net")
      lines.pop if lines.last.includes?("eqeq.net")
    when "xbiquge"
      lines.shift if lines.first.starts_with?("笔趣阁")
    when "bxwxorg"
      lines.shift if lines.first =~ /bxwx66|bxwxorg/
      lines.pop if lines.last.includes?("bxwxorg.com")
    when "duokan8"
      lines.shift if lines.first == "<b></b>"
      lines.update(0, &.sub(/.+<\/h1>\s*/, ""))
      lines.map!(&.sub("</div>", "").sub("<r />", "")).reject!(&.empty?)
    when "ptwxz"
      lines.shift if lines.first.includes?(title)
    when "biqu5200"
      trash = title.tr(" ", "").sub(/（.+）/, "")
      lines[0] = lines[0].gsub(/^.*#{trash}\s*/, "")

      lines.map! do |line|
        line
          .gsub(/厺厽\s.+\s厺厽。?/, "")
          .gsub(/攫欝攫欝?。?/, "")
          .gsub(/巘戅.+戅。?/, "")
      end

      lines.shift if lines[0]?.try(&.starts_with?("恋上你看书网"))
    else
      lines.pop if lines.last == "(本章完)"
    end

    lines
  rescue err
    puts "<rm_text> [#{@sname}/#{@snvid}/#{@schid}] error:".colorize.red
    puts err.inspect_with_backtrace.colorize.red

    [] of String
  end

  private def extract_hetushu_paras
    orders = get_hetushu_line_order(@file.sub(".html.gz", ".meta"))

    res = Array(String).new(orders.size, "")
    jmp = 0

    page.css("#content > div:not([class])").each_with_index do |node, idx|
      ord = orders[idx]? || 0

      if ord < 5
        jmp += 1
      else
        ord -= jmp
      end

      res[ord] = node.inner_text(deep: false).strip
    end

    res
  end

  private def get_hetushu_line_order(meta_file : String, retry = false)
    File.delete(meta_file) if retry

    base64 = page.attr("meta[name=client]", "content") do
      hetushu_encrypt_string(meta_file)
    end

    Base64.decode_string(base64).split(/[A-Z]+%/).map(&.to_i)
  rescue
    return [] of Int32 if retry
    get_hetushu_line_order(meta_file, retry: true)
  end

  private def hetushu_encrypt_string(meta_file : String)
    return File.read(meta_file) if File.exists?(meta_file)
    json_link = @link.sub("#{@schid}.html", "r#{@schid}.json")

    headers = HTTP::Headers{
      "Referer"          => @link,
      "Content-Type"     => "application/x-www-form-urlencoded",
      "X-Requested-With" => "XMLHttpRequest",
      "Cookie"           => "PHPSESSID=48grk8h3bi58q13rhbjp1kaa73",
    }

    puts "-- GET: <#{json_link}>".colorize.blue
    HTTP::Client.get(json_link, headers: headers) do |res|
      res.headers["token"].tap { |token| File.write(meta_file, token) }
    end
  end
end

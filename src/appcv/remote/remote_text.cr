require "http/client"

require "../../_util/site_link"
require "../../_util/time_util"
require "../../_util/text_util"
require "../../_util/http_util"
require "./html_parser"

class CV::RemoteText
  # cache folder path
  PATH = "var/chaps/.html/%s/%s/%s.html.gz"

  getter sname : String
  getter s_bid : Int32
  getter s_cid : Int32
  getter title : String

  @ttl : Time::Span | Time::MonthSpan

  getter file : String
  getter link : String

  def initialize(@sname, @s_bid, @s_cid, @ttl = 10.years, @lbl = "-/-")
    @file = PATH % {@sname, @s_bid, @s_cid}
    @link = SiteLink.text_url(sname, s_bid, s_cid)

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
    when "ptwxz"
      node = page.css("h1").first
      node.css("a").each(&.remove!)
      TextUtil.fix_spaces(node.inner_text).sub("正文 ", "").strip
    when "duokan8"
      extract_title("#read-content > h2")
        .sub(/^章节目录\s*/, "")
        .sub(/《.+》正文\s/, "")
    when "hetushu"
      page.text("#content .h2")
    when "kanshu8"
      page.attr("h1 > a", "title")
    when "zhwenpg"
      extract_title("h2")
    else
      extract_title("h1")
    end
  end

  # remove volume label from chap title
  private def extract_title(sel : String) : String
    title, chvol = TextUtil.format_title(page.text(sel))
    chvol.empty? ? title : "#{chvol}  #{title}"
  end

  getter paras : Array(String) do
    case @sname
    when "hetushu" then extract_hetushu_paras
    when "69shu"
      lines = extract_paras(".txtnav")
      lines.empty? ? extract_paras(".yd_text2") : lines
    when "uukanshu"
      lines = extract_paras("#contentbox")
      lines.map! do |line|
        line.gsub(/\s*[uＵ][uＵ]看书\P{Han}+[ｃc][oｏ][ｍm]\s*/i, "")
      end
      lines.reject!(&.empty?)
    when "uuks"
      extract_paras("#contentbox")
    when "ptwxz"
      paras = extract_paras("body")
      paras.shift if paras.first.includes?(title)
      paras
    when "bxwxio"
      lines = extract_paras("#content")
      lines.shift if lines[0].includes?("bxwx")
      lines
    when "kanshu8"
      lines = extract_paras(".pt-read-text")

      (8..12).each do |idx|
        break unless line = lines[idx]?
        lines[idx] = line.sub(/\s*(记住|首发|一秒).+[nｎ][eｅ][tｔ]\s*/, "")
      end

      lines
    when "xbiquge"
      lines = extract_paras("#content")
      lines.shift if lines[0].includes?("笔趣阁")
      lines
    when "duokan8"
      lines = extract_paras("#htmlContent > p")
      lines.shift if lines.first == "<b></b>"
      lines.update(0, &.sub(/.+<\/h1>\s*/, ""))
      lines.map!(&.sub("</div>", "").sub("<r />", "")).reject!(&.empty?)
      lines
    when "biqu5200"
      lines = extract_paras("#content")
      trash = Regex.escape(title.tr(" ", "").sub(/\(|（.+）|\)/, "").strip)
      lines[0] = lines[0].gsub(/^.*#{trash}\s*/, "")
      lines.shift if lines[0]?.try(&.starts_with?("恋上你看书网"))

      lines.map! do |line|
        line
          .gsub(/厺厽\s.+\s厺厽。?/, "")
          .gsub(/攫欝攫欝?。?/, "")
          .gsub(/巘戅.+戅。?/, "")
      end
    when "5200"
      lines = extract_paras("#content")
      lines.pop if lines.last.ends_with?("更新速度最快。")
      lines
    when "bxwxorg"
      lines = extract_paras("#content")

      lines.shift if lines.first =~ /bxwx66|bxwxorg/
      lines.pop if lines.last =~ /bxwx66|bxwxorg/
      lines.clear if lines.first == "抱歉！..."

      lines
    when "sdyfcm"
      lines = extract_paras("#content")
      3.times { lines.shift } if lines[1].includes?("eqeq.net")
      lines.pop if lines.last.includes?("eqeq.net")
      lines
    when "jx_la"
      lines = extract_paras("#content")
      lines.pop if lines.last.starts_with?("正在手打中")
      lines
    when "biqugee"
      paras = extract_paras("#content")
      paras.empty? ? extract_paras(".box_con") : paras
    when "zhwenpg"
      lines = extract_paras("#tdcontent .content")
      title.split(/\s+/).each { |x| lines[0] = lines[0].sub(/^#{x}\s*/, "") }
      lines
    else
      extract_paras("#content")
    end
  end

  private def extract_paras(sel : String = "#content")
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
    lines.pop if lines.last == "(本章完)"

    lines
  rescue err
    Log.error { "[#{@sname}/#{@s_bid}/#{@s_cid}] remote text error: #{err}" }
    [] of String
  end

  private def extract_hetushu_paras
    orders = get_hetushu_line_order(@file.sub(".html.gz", ".meta"))

    res = Array(String).new(orders.size, "")
    jmp = 0

    nodes = page.css("#content > div:not([class])")
    nodes.each_with_index do |node, idx|
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
    json_link = @link.sub("#{@s_cid}.html", "r#{@s_cid}.json")

    headers = HTTP::Headers{
      "Referer"          => @link,
      "Content-Type"     => "application/x-www-form-urlencoded",
      "X-Requested-With" => "XMLHttpRequest",
      "Cookie"           => "PHPSESSID=48grk8h3bi58q13rhbjp1kaa73",
    }

    Log.info { "GET: <#{json_link}>".colorize.blue }
    HTTP::Client.get(json_link, headers: headers) do |res|
      res.headers["token"].tap { |token| File.write(meta_file, token) }
    end
  end
end

require "../cutil/time_utils"
require "../cutil/text_utils"
require "../cutil/http_utils"
require "./shared/html_parser"

class CV::RmText
  # cache folder path
  def self.c_dir(sname : String, snvid : String) : String
    "_db/.cache/#{sname}/texts/#{snvid}"
  end

  def self.mkdir!(sname : String, snvid)
    ::FileUtils.mkdir_p(c_dir(sname, snvid))
  end

  getter sname : String
  getter snvid : String
  getter schid : String

  getter file : String { "#{RmText.c_dir(@sname, @snvid)}/#{@schid}.html.gz" }

  getter link : String do
    case @sname
    when "nofff"    then "https://www.nofff.com/#{snvid}/#{schid}/"
    when "69shu"    then "https://www.69shu.com/txt/#{snvid}/#{schid}"
    when "jx_la"    then "https://www.jx.la/book/#{snvid}/#{schid}.html"
    when "qu_la"    then "https://www.qu.la/book/#{snvid}/#{schid}.html"
    when "rengshu"  then "http://www.rengshu.com/book/#{snvid}/#{schid}"
    when "xbiquge"  then "https://www.xbiquge.so/book/#{snvid}/#{schid}.html"
    when "biqubao"  then "https://www.biqubao.com/book/#{snvid}/#{schid}.html"
    when "bxwxorg"  then "https://www.bxwxorg.com/read/#{snvid}/#{schid}.html"
    when "zhwenpg"  then "https://novel.zhwenpg.com/r.php?id=#{schid}"
    when "hetushu"  then "https://www.hetushu.com/book/#{snvid}/#{schid}.html"
    when "duokan8"  then "http://www.duokanba.info/#{prefixed_snvid}/#{schid}.html"
    when "paoshu8"  then "http://www.paoshu8.com/#{prefixed_snvid}/#{schid}.html"
    when "5200"     then "https://www.5200.tv/#{prefixed_snvid}/#{schid}.html"
    when "shubaow"  then "https://www.shubaow.net/#{prefixed_snvid}/#{schid}.html"
    when "bqg_5200" then "https://www.biquge5200.com/#{prefixed_snvid}/#{schid}.html"
    else                 raise "Unsupported remote source <#{sname}>!"
    end
  end

  def prefixed_snvid
    "#{@snvid.to_i // 1000}_#{@snvid}"
  end

  alias TimeSpan = Time::Span | Time::MonthSpan

  def initialize(@sname, @snvid, @schid, @ttl : TimeSpan = 10.years, @label = "1/1")
  end

  getter page : HtmlParser do
    encoding = HttpUtils.encoding_for(@sname)
    html = HttpUtils.load_html(link, file, @ttl, @label, encoding)
    HtmlParser.new(html)
  end

  def save!(file : String) : Nil
    File.open(file, "w") do |io|
      io << title
      paras.each { |line| io << "\n" << line }
    end

    puts "- <chtext> `#{file}` saved!".colorize.green
  end

  getter title : String do
    case @sname
    when "duokan8"
      extract_title("#read-content > h2")
        .sub(/^章节目录\s*/, "")
        .sub(/《.+》正文\s/, "")
    when "hetushu" then page.text("#content .h2")
    when "zhwenpg" then extract_title("h2")
    else                extract_title("h1")
    end
  end

  # remove volume label from chap title
  private def extract_title(sel : String) : String
    title = page.text(sel)
    TextUtils.format_title(title)[0]
  end

  getter paras : Array(String) do
    case @sname
    when "hetushu" then extract_hetushu_paras
    when "69shu"   then extract_69shu_paras
    when "zhwenpg" then extract_paras("#tdcontent .content")
    when "duokan8" then extract_paras("#htmlContent > p")
    else                extract_paras("#content")
    end
  end

  private def extract_69shu_paras
    unless node = page.find(".txtnav")
      return extract_paras(".yd_text2")
    end

    node.children.each do |tag|
      tag.remove! if {"script", "div", "h1"}.includes?(tag.tag_name)
    end

    lines = TextUtils.split_html(node.inner_text("\n"))
    lines.shift if lines.first == title
    lines.pop if lines.last == "(本章完)"

    lines
  end

  private def extract_paras(sel : String)
    return [] of String unless node = page.find(sel)

    node.children.each do |tag|
      tag.remove! if {"script", "div"}.includes?(tag.tag_name)
    end

    if @sname == "bxwxorg"
      node.children.each do |tag|
        tag.remove! if tag.attributes["style"]?
      end
    end

    lines = TextUtils.split_html(node.inner_text("\n"))
    lines.shift if lines.first == title

    case @sname
    when "zhwenpg"
      title.split(/\s+/).each { |x| lines[0] = lines[0].sub(/^#{x}\s*/, "") }
    when "jx_la"
      lines.pop if lines.last.starts_with?("正在手打中")
    when "5200"
      lines.pop if lines.last.ends_with?("更新速度最快。")
    when "nofff"
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
    when "bqg_5200"
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
    puts "<rm_text> [#{@sname}/#{@snvid}/#{@schid}] error: #{err}".colorize.red
    [] of String
  end

  private def extract_hetushu_paras
    client = hetushu_encrypt_string
    orders = Base64.decode_string(client).split(/[A-Z]+%/).map(&.to_i)

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

  private def hetushu_encrypt_string
    page.attr("meta[name=client]", "content", nil).try { |attr| return attr }

    meta_file = file.sub(".html.gz", ".meta")
    return File.read(meta_file) if File.exists?(meta_file)

    json_link = link.sub("#{@schid}.html", "r#{@schid}.json")

    headers = HTTP::Headers{
      "Referer"          => link,
      "X-Requested-With" => "XMLHttpRequest",
    }

    puts "-- GET: <#{json_link}>".colorize.blue
    HTTP::Client.get(json_link, headers: headers) do |res|
      res.headers["token"].tap { |token| File.write(meta_file, token) }
    end
  end
end

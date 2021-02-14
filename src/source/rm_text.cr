require "myhtml"
require "colorize"
require "file_utils"

require "../_utils/time_utils"
require "../_utils/file_utils"
require "../_utils/text_utils"
require "../_utils/http_utils"

class CV::RmText
  def self.init(sname : String, snvid : String, schid : String,
                expiry : Time = Time.utc - 10.years, freeze : Bool = true)
    file = path_for(sname, snvid, schid)
    expiry = TimeUtils::DEF_TIME if sname == "jx_la"

    unless html = FileUtils.read(file, expiry)
      url = url_for(sname, snvid, schid)
      html = HttpUtils.get_html(url, encoding: HttpUtils.encoding_for(sname))

      if freeze
        ::FileUtils.mkdir_p(File.dirname(file))
        File.write(file, html)
      end
    end

    new(sname, snvid, schid, file: file, html: html)
  end

  def self.path_for(sname : String, snvid : String, schid : String)
    "_db/.cache/#{sname}/texts/#{snvid}/#{schid}.html"
  end

  def self.url_for(sname : String, snvid : String, schid : String) : String
    case sname
    when "nofff"    then "https://www.nofff.com/#{snvid}/#{schid}/"
    when "69shu"    then "https://www.69shu.com/txt/#{snvid}/#{schid}"
    when "jx_la"    then "https://www.jx.la/book/#{snvid}/#{schid}.html"
    when "qu_la"    then "https://www.qu.la/book/#{snvid}/#{schid}.html"
    when "rengshu"  then "http://www.rengshu.com/book/#{snvid}/#{schid}"
    when "xbiquge"  then "https://www.xbiquge.cc/book/#{snvid}/#{schid}.html"
    when "zhwenpg"  then "https://novel.zhwenpg.com/r.php?id=#{schid}"
    when "hetushu"  then "https://www.hetushu.com/book/#{snvid}/#{schid}.html"
    when "duokan8"  then "http://www.duokanba.info/#{prefixed(snvid, schid)}"
    when "paoshu8"  then "http://www.paoshu8.com/#{prefixed(snvid, schid)}"
    when "5200"     then "https://www.5200.tv/#{prefixed(snvid, schid)}"
    when "shubaow"  then "https://www.shubaow.net/#{prefixed(snvid, schid)}"
    when "bqg_5200" then "https://www.biquge5200.com/#{prefixed(snvid, schid)}"
    else
      raise "Unsupported remote source <#{sname}>!"
    end
  end

  private def self.prefixed(snvid : String, schid : String)
    "#{snvid.to_i // 1000}_#{snvid}/#{schid}.html"
  end

  getter sname : String
  getter snvid : String
  getter schid : String
  getter file : String

  def initialize(@sname, @snvid, @schid, @file, html = File.read(@file))
    @rdoc = Myhtml::Parser.new(html)
  end

  getter title : String do
    case @sname
    when "duokan8"
      extract_title("#read-content > h2")
        .sub(/^章节目录\s*/, "")
        .sub(/《.+》正文\s/, "")
    when "hetushu" then @rdoc.css("#content .h2").first.inner_text
    when "zhwenpg" then extract_title("h2")
    else                extract_title("h1")
    end
  end

  private def extract_title(sel : String) : String
    return "" unless node = @rdoc.css(sel).first?
    TextUtils.format_title(node.inner_text)[0]
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
    unless node = @rdoc.css(".txtnav").first?
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
    return [] of String unless node = @rdoc.css(sel).first?

    node.children.each do |tag|
      tag.remove! if {"script", "div"}.includes?(tag.tag_name)
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
    puts "<remote_text> [#{@sname}/#{@snvid}/#{@schid}] error: #{err}".colorize.red
    [] of String
  end

  private def extract_hetushu_paras
    client = hetushu_encrypt_string
    orders = Base64.decode_string(client).split(/[A-Z]+%/)

    res = Array(String).new(orders.size, "")
    jmp = 0

    inp = @rdoc.css("#content div:not([class])").map_with_index do |node, idx|
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

  private def hetushu_encrypt_string
    if node = @rdoc.css("meta[name=client]").first?
      return node.attributes["content"]
    end

    meta_file = @file.sub(".html", ".meta")
    return File.read(meta_file) if File.exists?(meta_file)

    html_url = RmText.url_for(@sname, @snvid, @schid)
    json_url = html_url.sub("#{@schid}.html", "r#{@schid}.json")

    headers = HTTP::Headers{
      "Referer"          => html_url,
      "X-Requested-With" => "XMLHttpRequest",
    }

    HTTP::Client.get(json_url, headers: headers) do |res|
      res.headers["token"].tap { |token| File.write(meta_file, token) }
    end
  end
end

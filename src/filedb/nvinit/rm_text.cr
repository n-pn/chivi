require "myhtml"
require "colorize"
require "file_utils"

require "../../shared/*"

class CV::RmText
  def self.init(seed : String, sbid : String, scid : String,
                expiry : Time = Time.utc - 10.years, freeze : Bool = true)
    file = path_for(seed, sbid, scid)
    expiry = TimeUtils::DEF_TIME if seed == "jx_la"

    unless html = FileUtils.read(file, expiry)
      url = url_for(seed, sbid, scid)
      html = HttpUtils.get_html(url, encoding: HttpUtils.encoding_for(seed))

      if freeze
        ::FileUtils.mkdir_p(File.dirname(file))
        File.write(file, html)
      end
    end

    new(seed, sbid, scid, file: file, html: html)
  end

  def self.path_for(seed : String, sbid : String, scid : String)
    "_db/.cache/#{seed}/texts/#{sbid}/#{scid}.html"
  end

  def self.url_for(seed : String, sbid : String, scid : String) : String
    case seed
    when "nofff"      then "https://www.nofff.com/#{sbid}/#{scid}/"
    when "69shu"      then "https://www.69shu.com/txt/#{sbid}/#{scid}"
    when "jx_la"      then "https://www.jx.la/book/#{sbid}/#{scid}.html"
    when "qu_la"      then "https://www.qu.la/book/#{sbid}/#{scid}.html"
    when "rengshu"    then "http://www.rengshu.com/book/#{sbid}/#{scid}"
    when "xbiquge"    then "https://www.xbiquge.cc/book/#{sbid}/#{scid}.html"
    when "zhwenpg"    then "https://novel.zhwenpg.com/r.php?id=#{scid}"
    when "hetushu"    then "https://www.hetushu.com/book/#{sbid}/#{scid}.html"
    when "duokan8"    then "http://www.duokan8.com/#{prefixed(sbid, scid)}"
    when "paoshu8"    then "http://www.paoshu8.com/#{prefixed(sbid, scid)}"
    when "5200"       then "https://www.5200.tv/#{prefixed(sbid, scid)}"
    when "shubaow"    then "https://www.shubaow.net/#{prefixed(sbid, scid)}"
    when "biquge5200" then "https://www.biquge5200.com/#{prefixed(sbid, scid)}"
    else                   raise "Unsupported remote source <#{seed}>!"
    end
  end

  private def self.prefixed(sbid : String, scid : String)
    "#{sbid.to_i // 1000}_#{sbid}/#{scid}.html"
  end

  getter seed : String
  getter sbid : String
  getter scid : String
  getter file : String

  def initialize(@seed, @sbid, @scid, @file, html = File.read(@file))
    @rdoc = Myhtml::Parser.new(html)
  end

  getter title : String do
    case @seed
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
    case @seed
    when "hetushu" then extract_hetushu_paras
    when "69shu"   then extract_paras(".yd_text2")
    when "zhwenpg" then extract_paras("#tdcontent .content")
    when "duokan8" then extract_paras("#htmlContent > p")
    else                extract_paras("#content")
    end
  end

  private def extract_paras(sel : String)
    return [] of String unless node = @rdoc.css(sel).first?

    node.children.each do |tag|
      tag.remove! if {"script", "div"}.includes?(tag.tag_name)
    end

    lines = TextUtils.split_html(node.inner_text("\n"))
    lines.shift if lines.first == title

    case @seed
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
      lines.update(0, &.sub(/.+<\/h1>\s*/, ""))
      lines.map!(&.sub("</div>", "")).reject!(&.empty?)
    else
      lines.pop if lines.last == "(本章完)"
    end

    lines
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

    html_url = RmText.url_for(@seed, @sbid, @scid)
    json_url = html_url.sub("#{@scid}.html", "r#{@scid}.json")

    headers = HTTP::Headers{
      "Referer"          => html_url,
      "X-Requested-With" => "XMLHttpRequest",
    }

    HTTP::Client.get(json_url, headers: headers) do |res|
      res.headers["token"].tap { |token| File.write(meta_file, token) }
    end
  end
end

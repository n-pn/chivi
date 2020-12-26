require "myhtml"
require "colorize"
require "file_utils"

require "../shared/file_utils"
require "../shared/seed_utils"
require "../shared/http_utils"

module Chivi::RmText
  extend self

  def init(seed : String, sbid : String, scid : String, expiry = Time.utc - 2.years, freeze = true)
    html_url = chap_url(seed, sbid, scid)

    out_file = "_db/.cache/#{seed}/texts/#{sbid}/#{scid}.html"
    ::FileUtils.mkdir_p(File.dirname(out_file)) if freeze

    expiry = SeedUtils::DEF_TIME if seed == "jx_la"
    parser_for(seed).new(html_url, out_file, expiry, freeze)
  end

  def parser_for(seed : String) : Class
    case seed
    when "5200"       then RT_5200
    when "jx_la"      then RT_Jx_la
    when "69shu"      then RT_69shu
    when "nofff"      then RT_Nofff
    when "rengshu"    then RT_Rengshu
    when "xbiquge"    then RT_Xbiquge
    when "paoshu8"    then RT_Paoshu8
    when "duokan8"    then RT_Duokan8
    when "shubaow"    then RT_Shubaow
    when "hetushu"    then RT_Hetushu
    when "zhwenpg"    then RT_Zhwenpg
    when "biquge5200" then RT_Biquge5200
    else                   raise "Unsupported remote source <#{seed}>!"
    end
  end

  def chap_url(seed : String, sbid : String, scid : String) : String
    case seed
    when "nofff"      then "https://www.nofff.com/#{sbid}/#{scid}/"
    when "69shu"      then "https://www.69shu.com/#{sbid}/#{scid}"
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

  private def prefixed(sbid : String, scid : String)
    "#{sbid.to_i // 1000}_#{sbid}/#{scid}.html"
  end

  class RT_Generic
    # input

    getter html_url : String
    getter out_file : String

    # output

    getter html : String { fetch! }
    getter rdoc : Myhtml::Parser { Myhtml::Parser.new(html) }

    getter title : String { raw_title("h1") }
    getter paras : Array(String) { raw_paras("#content") }

    def initialize(@html_url, @out_file, @expiry : Time, @freeze : Bool = true)
    end

    def fetch!
      unless html = FileUtils.read(@out_file, @expiry)
        html = HttpUtils.get_html(@html_url)
        File.write(@out_file, html) if @freeze
      end

      html
    end

    protected def raw_title(sel : String = "h1")
      return "" unless node = rdoc.css(sel).first?
      SeedUtils.format_title(node.inner_text)
    end

    protected def raw_paras(sel : String = "#content")
      return [] of String unless node = rdoc.css(sel).first?

      node.children.each do |tag|
        tag.remove! if {"script", "div"}.includes?(tag.tag_name)
      end

      lines = SeedUtils.split_html(node.inner_text("\n"))

      lines.shift if lines.first == title
      lines.pop if lines.last == "(本章完)"

      lines
    end
  end

  class RT_69shu < RT_Generic
    getter paras : Array(String) { raw_paras(".yd_text2") }
  end

  class RT_5200 < RT_Generic
    getter paras : Array(String) { extract_paras }

    def extract_paras
      paras = raw_paras("#content")
      paras.pop if paras.last.ends_with?("更新速度最快。")
      paras
    end
  end

  class RT_Jx_la < RT_Generic
    getter paras : Array(String) { extract_paras }

    def extract_paras
      paras = raw_paras("#content")
      paras.pop if paras.last.starts_with?("正在手打中")
      paras
    end
  end

  class RT_Nofff < RT_Generic
    getter paras : Array(String) { extract_paras }

    def extract_paras
      paras = raw_paras("#content")

      3.times { paras.shift } if paras[1].includes?("eqeq.net")
      paras.pop if paras.last.includes?("eqeq.net")

      paras
    end
  end

  class RT_Paoshu8 < RT_Generic; end

  class RT_Xbiquge < RT_Generic
    getter paras : Array(String) { extract_paras }

    def extract_paras
      paras = raw_paras("#content")
      paras.shift if paras.first.starts_with?("笔趣阁")
      paras
    end
  end

  class RT_Shubaow < RT_Generic; end

  class RT_Rengshu < RT_Generic; end

  class RT_Biquge5200 < RT_Generic; end

  class RT_Zhwenpg < RT_Generic
    getter title : String { raw_title("h2") }
    getter paras : Array(String) { extract_paras }

    def extract_paras
      paras = raw_paras("#tdcontent .content")

      title.split(/\s+/).each do |frag|
        paras[0] = paras[0].sub(/^#{frag}\s*/, "")
      end

      paras
    end
  end

  class RT_Hetushu < RT_Generic
    getter title : String { raw_title("#content .h2") }
    getter paras : Array(String) { extract_paras }

    private def extract_paras
      client = get_encrypt_string
      orders = Base64.decode_string(client).split(/[A-Z]+%/)

      res = Array(String).new(orders.size, "")
      jmp = 0

      inp = rdoc.css("#content div:not([class])").map_with_index do |node, idx|
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

    private def get_encrypt_string
      if node = rdoc.css("meta[name=client]").first?
        return node.attributes["content"]
      end

      meta_file = @out_file.sub(".html", ".meta")
      FileUtils.read(meta_file, @expiry).try { |x| return x }

      HTTP::Client.get(content_url, ajax_header) do |res|
        token = res.headers["token"]
        # puts "-- seed token for [#{@html_url}] saved -- ".colorize.dark_gray
        token.tap { |t| File.write(meta_file, t) if @freeze }
      end
    end

    def content_url
      scid = File.basename(@html_url, ".html")
      @html_url.sub("#{scid}.html", "r#{scid}.json")
    end

    private def ajax_header
      HTTP::Headers{
        "X-Requested-With" => "XMLHttpRequest",
        "Referer"          => @html_url,
      }
    end
  end

  class RT_Duokan8 < RT_Generic
    getter title : String { extract_title }
    getter paras : Array(String) { extract_paras }

    def extract_title
      raw_title("#read-content > h2")
        .sub(/^章节目录\s*/, "")
        .sub(/《.+》正文\s/, "")
    end

    def extract_paras
      paras = raw_paras("#htmlContent > p")
      paras.update(0, &.sub(/.+<\/h1>\s*/, ""))
      paras.map!(&.sub("</div>", "")).reject!(&.empty?)
    end
  end
end

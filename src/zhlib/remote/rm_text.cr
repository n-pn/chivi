require "./rm_site"
require "./rm_page"

class ZH::RmText
  getter sname : String

  getter bid : Int32
  getter cid : Int32

  @site : RmSite
  @page : RmPage

  class_getter path = "var/texts/.cache/%{sname}/%{bid}/%{cid}.htm.zst"

  def initialize(@sname, @bid, @cid, reset : Bool = false)
    @site = RmSite[sname]

    link = @site.text_link(bid, cid)

    path = @@path % {sname: sname, bid: bid, cid: cid}

    File.delete(path) if reset && File.exists?(path)
    Dir.mkdir_p(File.dirname(path))

    @page = RmPage.load!(path) { RmPage.fetch!(link, path, @site.encoding) }
  end

  getter title : String do
    case @site.text.tkind
    when 2
      @page.css("h1 > a").each(&.remove!)
      @page.get(@site.text.title_css).sub(/正文\s*/, "")
    when 3
      @page.get(@site.text.title_css).sub(/^章节目录\s*/, "").sub(/《.+》正文\s*/, "")
    else
      @page.get(@site.text.title_css)
    end
  end

  getter paras : Array(String) do
    case @site.text.pkind
    when 1 then kind_1_paras
    else        kind_0_paras
    end
  rescue err
    Log.error(exception: err) { "[#{@sname}/#{@bid}/#{@cid}] parse error: #{err}" }
    [] of String
  end

  def kind_0_paras
    node = @page.css(@site.text.paras_css, &.first)

    @page.remove!(node, :script, :div, :h1, :table)

    lines = node.inner_text("\n").lines
    lines.map! { |x| @page.clean(x) }.reject!(&.empty?)

    lines.shift if reject_first_line?(lines.first)
    lines.pop if lines.last == "(本章完)"

    lines
  end

  def reject_first_line?(first : String)
    first =~ /^笔趣阁|笔下文学|，\p{Han}/ || first.sub(self.title, "") !~ /\p{Han}/
  end

  private def kind_1_paras
    path = @@path % {sname: @sname, bid: @bid, cid: @cid}
    orders = type_1_line_order(path.sub(".htm.zst", ".meta"))

    res = Array(String).new(orders.size) { "" }
    jmp = 0

    nodes = @page.css("#content > div:not([class])")

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

  private def type_1_line_order(file : String, retry = false)
    File.delete(file) if retry
    base64 = type1_encrypt_string(file)
    Base64.decode_string(base64).split(/[A-Z]+%/).map(&.to_i)
  rescue err
    retry ? raise err : type_1_line_order(file, retry: true)
  end

  private def type1_encrypt_string(file : String)
    return File.read(file) if File.exists?(file)

    text_link = @site.text_link(bid, cid)
    json_link = text_link.sub("#{cid}.html", "r#{cid}.json")

    headers = HTTP::Headers{
      "Referer"          => text_link,
      "Content-Type"     => "application/x-www-form-urlencoded",
      "X-Requested-With" => "XMLHttpRequest",
      "Cookie"           => @site.text.cookie,
    }

    HTTP::Client.get(json_link, headers: headers) do |res|
      res.headers["token"].tap { |x| File.write(file, x) }
    end
  end
end

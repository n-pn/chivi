require "./rm_site"
require "./rm_page"

class ZH::RmText
  class_getter path = "var/texts/.cache/%{sname}/%{bid}/%{cid}.htm.zst"

  def self.init(sname : String, bid : Int32, cid : Int32, reset = false)
    site = RmSite[sname]

    link = site.chap_link(bid, cid)
    path = @@path % {sname: sname, bid: bid, cid: cid}

    File.delete(path) if reset && File.exists?(path)
    Dir.mkdir_p(File.dirname(path))

    new(link, path, site)
  end

  getter link : String
  getter path : String

  @chap : RmSite::Chap
  @page : RmPage

  def initialize(@link, @path, site : RmSite)
    @chap = site.chap
    @page = RmPage.load!(link, path, site.encoding)
  end

  getter bname : String { @page.get(@chap.bname) }

  getter title : String do
    @page.get(@chap.title)
      .sub(/^#{Regex.escape(bname)}\s*/, "")
      .sub(/^章节目录\s*/, "")
      .sub(/(《.+》)?正文\s*/, "")
  end

  getter paras : Array(String) do
    return get_paras_wrong_order if @chap.reorder

    node = @page.css(@chap.paras, &.first)
    @page.remove!(node, :script, :div, :h1, :table)

    lines = node.inner_text("\n").lines
    lines.map! { |x| TextUtil.trim_spaces(x) }.reject!(&.empty?)

    lines.shift if reject_first_line?(lines.first)
    lines.pop if lines.last == "(本章完)"

    lines
  rescue err
    Log.error(exception: err) { "error extracting body" }
    [] of String
  end

  def reject_first_line?(first : String)
    first =~ /^笔趣阁|笔下文学|，#{Regex.escape bname}/ || first.sub(self.title, "") !~ /\p{Han}/
  end

  private def get_paras_wrong_order
    reorder = get_reorder(@path.sub(".htm.zst", ".tok"))

    res = Array(String).new(reorder.size, "")
    jmp = 0

    nodes = @page.css("#content > div:not([class])")

    nodes.each_with_index do |node, idx|
      ord = reorder[idx]? || 0

      if ord < 5
        jmp += 1
      else
        ord -= jmp
      end

      res[ord] = node.inner_text(deep: false).strip
    end

    res
  end

  private def get_reorder(file : String, retry = false)
    File.delete(file) if retry
    base64 = encrypt_string(file)
    Base64.decode_string(base64).split(/[A-Z]+%/).map(&.to_i)
  rescue err
    retry ? raise err : get_reorder(file, retry: true)
  end

  private def encrypt_string(file : String)
    return File.read(file) if File.exists?(file)

    headers = HTTP::Headers{
      "Referer"          => @link,
      "Content-Type"     => "application/x-www-form-urlencoded",
      "X-Requested-With" => "XMLHttpRequest",
      "Cookie"           => @chap.cookie,
    }

    link = @link.sub(/(\d+).html$/) { "r#{$1}.json" }

    HTTP::Client.get(link, headers: headers) do |res|
      res.headers["token"].tap { |x| File.write(file, x) }
    end
  end
end

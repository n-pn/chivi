require "../utils/time_utils"
require "../utils/text_utils"

require "./rm_spider"

class CV::RmChtext
  getter sname : String
  getter snvid : String
  getter schid : String

  def initialize(@sname, @snvid, @schid, valid = 10.years, label = "1/1")
    file = RmSpider.chtext_file(@sname, @snvid, @schid)
    link = RmSpider.chtext_link(@sname, @snvid, @schid)

    html = RmSpider.fetch(file, link, sname: @sname, valid: valid, label: label)
    @rdoc = Myhtml::Parser.new(html)
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

    html_file = RmSpider.chtext_file(@sname, @snvid, @schid)
    meta_file = html_file.sub(".html", ".meta")
    return File.read(meta_file) if File.exists?(meta_file)

    html_link = RmSpider.chtext_link(@sname, @snvid, @schid)
    json_link = html_link.sub("#{@schid}.html", "r#{@schid}.json")

    headers = HTTP::Headers{
      "Referer"          => html_link,
      "X-Requested-With" => "XMLHttpRequest",
    }

    puts "-- HIT: <#{json_link}>".colorize.blue
    HTTP::Client.get(json_link, headers: headers) do |res|
      res.headers["token"].tap { |token| File.write(meta_file, token) }
    end
  end
end

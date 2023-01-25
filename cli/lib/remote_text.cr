require "lexbor"
require "../../src/_util/text_util"

class RmTextParser
  def initialize(@sname, @file : String)
    @doc = Lexbor::Parser.new(File.read(file))
    @title = read_title
  end

  getter output : String do
    String.build { |io| build_output(io) }
  end

  private def build_output(io : String) : Nil
    io << @title << '\n'

    paras = read_paras()
    c_len = paras.sum(&.size)

    if c_len <= 4500
      limit = c_len
    else
      p_len = (c_len - 1) // 3000 + 1
      limit = c_len // p_len
    end

    count = 0

    paras.each_line do |line|
      if count > limit
        io << '\n'
        count = 0
      end

      io << '\n' << line
      count += line.size
    end
  end

  private def find(query : String)
    @doc.css(query, &.first?)
  end

  private def get_text(query : String, sep = "  ")
    return "" unless node = find(query)
    TextUtil.trim_spaces(node.inner_text(sep))
  end

  private def get_attr(query : String, name : String)
    find(query).try(&.attributes[name]?) || ""
  end

  private def read_title
    case @sname
    when "hetushu"
      get_text("#content .h2")
    when "ptwxz"
      node = @doc.css("h1").first
      node.css("a").each(&.remove!)
      TextUtil.fix_spaces(node.inner_text).sub("正文 ", "").strip
    when "duokan8"
      extract_title("#read-content > h2")
        .sub(/^章节目录\s*/, "")
        .sub(/《.+》正文\s/, "")
    when "kanshu8"
      get_attr("h1 > a", "title")
    else
      extract_title("h1")
    end
  end

  # remove volume label from chap title
  private def extract_title(sel : String) : String
    title, chdiv = TextUtil.format_title(get_text(sel))
    chdiv.empty? ? title : "#{chdiv}  #{title}"
  end

  def read_paras : Array(String)
    case @sname
    when "hetushu"
      extract_hetushu_paras
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
    when "biqugee"
      paras = extract_paras("#content")
      paras.empty? ? extract_paras(".box_con") : paras
    else
      extract_paras("#content")
    end
  end

  private def extract_paras(sel : String = "#content")
    return [] of String unless node = @doc.find(sel)

    @doc.clean_node(node, :script, :div, :h1, :table)

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
    base64 = File.read(meta_file)
    Base64.decode_string(base64).split(/[A-Z]+%/).map(&.to_i)

    res = Array(String).new(orders.size, "")
    jmp = 0

    nodes = @doc.css("#content > div:not([class])")
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

  private def get_hetushu_line_order(meta_file : String)
  end
end

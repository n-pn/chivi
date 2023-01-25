require "lexbor"
require "../../src/_util/text_util"
require "compress/gzip"

class HetushuText
  def initialize(@file : String)
    html = File.open(file) do |io|
      Compress::Gzip::Reader.open(io, &.gets_to_end)
    end
    @doc = Lexbor::Parser.new(html)
  end

  getter output : String do
    String.build do |io|
      io << get_text("#content .h2") << '\n'

      lines = extract_lines
      c_len = lines.sum(&.size)

      if c_len <= 4500
        limit = c_len
      else
        p_len = (c_len - 1) // 3000 + 1
        limit = c_len // p_len
      end

      count = 0

      lines.each do |line|
        if count > limit
          io << '\n'
          count = 0
        end

        io << '\n' << line
        count += line.size
      end
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

  private def extract_lines
    base64 = File.read(@file.sub(".html.gz", ".meta"))
    orders = Base64.decode_string(base64).split(/[A-Z]+%/).map(&.to_i)

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
end

require "lexbor"

require "../src/mt_ai/data/mt_spec"

class RawNode
  getter ptag = ""
  getter data : String | Array(RawNode) = ""

  def initialize(@ptag)
  end

  def add_data(@data : String) : Nil
  end

  def add_data(node : self) : Nil
    return if node.ptag == "-NONE-" || node.data == ""

    case data = @data
    in String
      @data = [node]
    in Array(RawNode)
      data << node
    end
  end

  def to_raw(io : IO)
    case data = @data
    in String
      io << data
    in Array(RawNode)
      data.each { |node| node.to_raw(io) }
    end
  end

  SEP = ' '

  def to_tok(io : IO) : Nil
    case data = @data
    in String
      io << SEP << data
    in Array(RawNode)
      data.each { |node| node.to_tok(io) }
    end
  end

  def to_pos(io : IO)
    return if @data == ""

    case data = @data
    in String
      io << SEP << @ptag
    in Array(RawNode)
      data.each { |node| node.to_pos(io) }
    end
  end

  def to_con(io : IO) : Nil
    return if @data == ""

    io << '(' << @ptag

    case data = @data
    in String
      io << ' ' << data
    in Array(RawNode)
      data.each do |node|
        io << ' '
        node.to_con(io)
      end
    end

    io << ')'
  end

  def self.parse(input : String)
    input = input.gsub(/\n[\t\s]+/, "")
    input = input.lchop("( ").rchop(" )")
    # input = input.sub(/\s{2,}\(/, " (").sub(/\)\s+\)/, "))")

    queue = [RawNode.new("TOP")]

    iter = input.each_char
    word = ""

    iter.each do |char|
      case char
      when '('
        ptag = ""
        word = ""
        while char = iter.next
          break unless char.is_a?(Char)
          break if char == ' '
          ptag += char
        end

        queue << RawNode.new(ptag)
      when ')'
        node = queue.pop

        unless word.empty?
          node.add_data(word)
          word = ""
        end

        unless last = queue.last?
          raise "invalid!" unless node.ptag == "TOP"
          return node.data.as(Array(RawNode))
        end

        # pp [node, last]
        last.add_data(node)
      when ' ', '\n', '\t'
        next
      else
        word += char
      end
    end

    queue.last.data.as(Array(RawNode))
  end
end

def parse_bracketed_file(inp_path : String)
  puts inp_path

  doc = Lexbor::Parser.new(File.read(inp_path))
  raw = doc.css("s").map(&.inner_text.strip)

  output = [] of AI::MtSpec
  origin = "ctb8@#{File.basename(inp_path)}"

  raw.each do |line|
    next if line.blank?
    # puts "\n----"
    # puts [line]

    data = RawNode.parse(line)

    data.each do |node|
      raw = String.build { |io| node.to_raw(io) }
      con = String.build { |io| node.to_con(io) }

      tok = String.build { |io| node.to_tok(io); io << ' ' }
      pos = String.build { |io| node.to_pos(io); io << ' ' }

      raise "invalid" unless tok.split(' ').size == pos.split(' ').size

      # puts [raw, con, tok, pos].join("\n----\n")

      entry = AI::MtSpec.new(raw, origin)

      entry.tok_gold = tok
      entry.pos_gold = pos
      entry.con_gold = con

      output << entry
    end
  end

  output
end

# parse_bracketed_file("/2tb/var.chivi/mtdic/cvmtl/inits/NLP/ctb8.0/data/bracketed/chtb_1133.mz")

DIR = "/2tb/var.chivi/mtdic/cvmtl/inits/NLP/ctb8.0/data/bracketed"

output = [] of AI::MtSpec

Dir.children(DIR).sort!.each do |child|
  output.concat parse_bracketed_file("#{DIR}/#{child}")
end

AI::MtSpec.db.open_tx do |db|
  output.each(&.upsert!(db: db))
end

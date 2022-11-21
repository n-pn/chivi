require "colorize"
require "./pos_tag"

abstract class MT::MtNode
  getter idx : Int32
  getter len : Int32

  getter ptag : Int32
  getter cost : Float32

  abstract def to_txt(io : IO)
  abstract def to_mtl(io : IO)
  abstract def inspect(io : IO)

  def initialize(@idx, @len, @ptag, @cost)
  end
end

class MT::MtTerm < MT::MtNode
  getter key : String
  getter val : String
  getter dic : Int32

  def initialize(@key, @val, @dic, @idx, @len, @ptag, @cost)
  end

  private def capitalize!
    String.build(@val.size) do |io|
      io << @val[0].upcase << @val[1..]
    end
  end

  def to_txt(io : IO) : Nil
    io << @val
  end

  def to_mtl(io : IO) : Nil
    io << '\t' << @val << 'ǀ' << @dic << 'ǀ' << @idx << 'ǀ' << @len
  end

  def inspect(io : IO = STDOUT, pad = -1) : Nil
    io << " " * pad if pad >= 0
    io << '[' << @val.colorize.light_yellow.bold << ']'
    io << ' ' << @key.colorize.blue
    io << ' ' << PosTag::PTAG_STR[@ptag]?.try(&.colorize.light_cyan)
    io << ' ' << @dic << ' ' << @idx.colorize.dark_gray
    io << '\n' if pad >= 0
  end
end

class MT::MtExpr < MT::MtNode
  getter list : Array(MtNode)

  def initialize(@list, @idx, @len, @ptag, @cost)
  end

  def to_txt(io : IO = STDOUT) : Nil
    prev = nil

    @list.each do |node|
      io << ' ' if prev && pad_space?(left, right)
      node.to_txt(io)
      prev = node unless node.pos.skipover?
    end
  end

  def apply_cap!(cap : Bool = false) : Bool
    @list.reduce(cap) { |memo, node| node.apply_cap!(memo) }
  end

  def to_mtl(io : IO = STDOUT) : Nil
    io << "〈0\t"
    prev = nil

    @list.each do |node|
      io << "\t " if prev && pad_space?(left, right)
      node.to_mtl(io)
      prev = node unless node.pos.skipover?
    end

    io << '〉'
  end

  private def pad_space?(left : MtNode, right : MtNode)
    true
  end

  def inspect(io : IO = STDOUT, pad = 0) : Nil
    io << " " * pad
    io << '{' << @tag.colorize.cyan

    ptag = PosTag::PTAG_STR[@ptag]? || "N/A"
    io << ':' << ptag.colorize.light_cyan << '}' << '\n'

    @list.each(&.inspect(io, pad &+ 2))

    io << " " * pad
    io << '{' >> '/' << @tag.colorize.cyan << '}'

    io << '\n' if pad > 0
  end
end

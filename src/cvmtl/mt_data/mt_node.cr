require "colorize"
require "./pos_tag"

abstract class MT::MtNode
  getter ptag : Int32
  getter size : Int32
  getter cost : Float64

  abstract def to_txt(io : IO)
  abstract def to_mtl(io : IO, idx : Int32)

  def initialize(@size, @ptag, @cost)
  end

  def tag_str
    PosTag.tag_str(@ptag)
  end
end

class MT::MtTerm < MT::MtNode
  # getter key : String
  getter val : String
  getter dic : Int8

  def initialize(@val, @dic, @size, @ptag, @cost : Float64)
  end

  def initialize(key : String, @val, @dic, tag : String, prio : Int32)
    @size = key.size
    @ptag = PosTag.map_tag(tag)

    # TODO: improve cost calculation
    @cost = prio > 0 ? size ** (1 + (prio * 2 + @dic) / 10_f64) : 0_f64
  end

  def title_val
    String.build(@val.size) { |io| io << @val[0].upcase << @val[1..] }
  end

  def to_txt(io : IO) : Nil
    io << @val
  end

  def to_mtl(io : IO, idx : Int32) : Nil
    io << '\t' << @val << 'ǀ' << @dic << 'ǀ' << idx << 'ǀ' << @size
  end
end

class MT::MtExpr < MT::MtNode
  getter list : Array(MtNode)

  def initialize(@list, @size, @ptag, @cost)
  end

  def to_txt(io : IO = STDOUT) : Nil
    # prev = nil

    @list.each do |node|
      io << ' ' # if prev && pad_space?(left, right)
      node.to_txt(io)
    end
  end

  def apply_cap!(cap : Bool = false) : Bool
    @list.reduce(cap) { |memo, node| node.apply_cap!(memo) }
  end

  def to_mtl(io : IO, idx : Int32) : Nil
    io << "〈0\t"
    # prev = nil

    @list.each do |node|
      io << "\t " # if prev && pad_space?(left, right)
      node.to_mtl(io, idx: idx)
      idx += node.size
    end

    io << '〉'
  end
end

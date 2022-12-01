require "colorize"
require "./pos_tag"

abstract class MT::MtNode
  getter ptag : Int32
  getter size : Int32
  getter cost : Int32

  abstract def to_txt(io : IO, apply_cap : Bool) : Bool
  abstract def to_mtl(io : IO, apply_cap : Bool) : Bool

  def initialize(@size, @ptag, @cost)
  end

  def tag_str
    PosTag.tag_str(@ptag)
  end

  def tag_attr
    PosTag.attr_of(@ptag)
  end
end

class MT::MtTerm < MT::MtNode
  # getter key : String
  getter val : String
  getter dic : Int8
  property idx : Int32 = 0

  def initialize(@val, @dic, @size, @ptag, @cost : Int32)
  end

  def initialize(key : String, @val, @dic, tag : String, prio : Int32)
    @size = key.size
    @ptag = PosTag.map_tag(tag)

    # TODO: improve cost calculation
    @cost = MtTerm.cost(size, prio)
  end

  # COSTS = {
  #   0, 3, 6, 9,
  #   0, 14, 18, 26,
  #   0, 25, 31, 40,
  #   0, 40, 45, 55,
  #   0, 58, 66, 78,
  # }

  COSTS = {
    100, 103, 106, 109,
    200, 214, 218, 226,
    300, 325, 331, 340,
    400, 440, 445, 455,
    500, 558, 566, 578,
  }

  def self.cost(size : Int32, prio : Int32 = 0) : Int32
    size &* 100 &+ 2 << (size + 1) &- 1

    # size > 5 ? size &* 100 &+ 2 << size : begin
    # COSTS[(size &- 1) &* 4 &+ prio]
    # end
  end

  def to_txt(io : IO, apply_cap : Bool) : Bool
    attr = self.tag_attr

    if attr.cap_relay? # for punctuation
      io << @val
      apply_cap || attr.cap_after?
    elsif apply_cap
      io << @val[0].upcase << @val[1..] unless @val.empty?
      attr.cap_after?
    else
      io << @val
      attr.cap_after?
    end
  end

  def to_mtl(io : IO, apply_cap : Bool) : Bool
    io << '\t'
    apply_cap = to_txt(io, apply_cap)
    io << 'ǀ' << @dic << 'ǀ' << @idx << 'ǀ' << @size
    apply_cap
  end

  def inspect(io : IO)
    io << '{' << @val << '/' << PosTag.tag_str(@ptag) << '/' << @dic << '}'
  end
end

module MT::MtSeri
  def to_txt(io : IO, apply_cap : Bool = false) : Bool
    attr = PosTag::Attr::NoSpaceR

    each do |node|
      node_attr = node.tag_attr

      unless node_attr.void?
        io << ' ' unless attr.no_space_r? || node_attr.no_space_l?
        attr = node_attr
      end

      apply_cap = node.to_txt(io, apply_cap: apply_cap)
    end

    apply_cap
  end

  def to_mtl(io : IO, apply_cap : Bool = false) : Bool
    io << "〈0\t"
    attr = PosTag::Attr::NoSpaceR

    each do |node|
      node_attr = node.tag_attr

      unless node_attr.void?
        io << "\t " unless attr.no_space_r? || node_attr.no_space_l?
        attr = node_attr
      end

      apply_cap = node.to_mtl(io, apply_cap: apply_cap)
    end

    io << '〉'
    apply_cap
  end
end

class MT::MtExpr < MT::MtNode
  include MtSeri

  getter list : Array(MtNode)

  def initialize(@list, @size, @ptag, @cost)
  end

  delegate each, to: @list
end

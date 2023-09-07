require "./mt_prop"
require "./mt_term"

module M2::MtNode
  getter ptag : Symbol
  getter attr : MtAttr = MtAttr::None

  getter size : Int32
  getter cost : Int32

  abstract def to_txt(io : IO, apply_cap : Bool) : Bool
  abstract def to_mtl(io : IO, apply_cap : Bool) : Bool

  # COSTS = {
  #   0, 3, 6, 9,
  #   0, 14, 18, 26,
  #   0, 25, 31, 40,
  #   0, 40, 45, 55,
  #   0, 58, 66, 78,
  # }

  COSTS = {
    103, 106, 109,
    214, 218, 226,
    325, 331, 340,
    440, 445, 455,
    558, 566, 578,
  }

  def self.term_cost(term_size : Int32, term_rank : Int32 = 0) : Int32
    term_rank < 1 ? 0 : 1020 &* (term_size) &* (term_size &- 1) &+ (term_rank * term_size) ** 2

    # case
    # when term_rank < 1 then 0
    # when term_size > 5 then 1000 &* term_size &* (term_size &+ term_rank)
    # else               1000 &* term_size &+ COSTS[(term_size &- 1) &* 3 &+ term_rank &- 1] * 4
    # end
  end

  def self.rule_cost(list_cost : Int32, list_size : Int32, rule_rank : Int32)
    list_cost &+ 10 &* list_size &* (list_size &- 1) &+ rule_rank
  end
end

module M2::MtSeri
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

class M2::MtAtom
  include MtNode

  getter term : MtTerm
  getter idx : Int32

  def initialize(key_char : Char, val_char : Char, @idx = 0)
    @term = MtTerm.new(key: key_char.to_s, val: val_char.to_s, dic: 0, prio: 3)
    @ptag = :RAW
    @size = 1
    @cost = 0
  end

  def initialize(key : String, val : String, dic : Int32, @ptag : Symbol, prio : Int32 = 0, @idx = 0)
    @term = MtTerm.new(key: key, val: val, dic: dic, prio: prio)
    @size = key.size
    @cost = MtNode.term_cost(@size, prio)
  end

  def initialize(@term, @ptag : Symbol, prio = term.prio, @idx = 0)
    @size = key.size
    @cost = MtNode.term_cost(@size, prio)
  end

  @[AlwaysInline]
  def to_txt(io : IO, apply_cap : Bool) : Bool
    @term.print_val(io, prop: @attr, apply_cap: apply_cap)
  end

  def to_mtl(io : IO, apply_cap : Bool) : Bool
    io << '\t'
    apply_cap = to_txt(io, apply_cap)
    io << 'ǀ' << @term.dic << 'ǀ' << @idx << 'ǀ' << @size
    apply_cap
  end

  def inspect(io : IO)
    io << '{' << @term.key << '/' << @term.val << '/' << @ptag << '/' << @term.dic << '}'
  end
end

class M2::MtPair
  include MtNode
  include MtSeri

  getter head : MtNode
  getter tail : MtNode

  def initialize(@head, @tail, @ptag = tail.ptag, @attr = tail.attr, rank = 3, @flip = false)
    @size = @head.size &+ @tail.size
    @cost = MtNode.rule_cost(@head.cost &+ @tail.cost, @size, rank)
  end

  def each(&)
    if @flip
      yield @tail
      yield @head
    else
      yield @head
      yield @tail
    end
  end
end

class M2::MtExpr
  include MtNode
  include MtSeri

  getter list : Slice(MtNode)
  @ords : Slice(Int32) | Nil = nil

  def initialize(@list : Slice(MtNode), @ptag = list.last.ptag, rank = 3, @ords = nil)
    @size = list.sum(&.size)
    @cost = MtNode.rule_cost(@size, list.sum(&.cost), rank)
  end

  def each(&)
    if ords = @ords
      ords.each { |ord| yield @list[ord] }
    else
      @list.each { |term| yield term }
    end
  end
end

# ameba:disable Style/TypeNames
class M2::NP_Node
  include MtNode
  include MtSeri

  @detm : MtNode | Nil = nil
  @noun : MtNode | Array(MtNode)

  @ptag = :NP

  def initialize(@noun : MtNode)
    @size = noun.size
    @cost = noun.cost
  end

  def initialize(@noun : MtNode, @detm : MtNode, rank = 4)
    @size = noun.size &+ detm.size
    @cost = MtNode.rule_cost(noun.cost &+ detm.cost, 2, rank)
  end

  def initialize(@noun : Array(MtNode))
    @size = noun.sum(&.size)
    @cost = noun.sum(&.cost)
  end

  def each(&)
    if detm = @detm
      # TODO: split to left and right nodes
      yield detm
    end

    noun = @noun

    if noun.is_a?(MtNode)
      yield noun
    else
      noun.each { |node| yield node }
    end
  end

  def to_txt(io : IO, apply_cap : Bool) : Bool
    @noun.to_txt(io, apply_cap)
  end

  def to_mtl(io : IO, apply_cap : Bool) : Bool
    @noun.to_txt(io, apply_cap)
  end
end

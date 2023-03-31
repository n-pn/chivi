require "../pos_tag"

module M2::MtNode
  getter ptag : String
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

class M2::MtTerm
  include MtNode

  getter key : String
  getter val : String
  getter dic : Int8

  def initialize(char : Char)
    @key = @val = char.to_s
    @dic = 0

    @ptag = "RAW"
    @size = 1
    @cost = 0
  end

  def initialize(@key, @val, @dic, @size, @ptag, @cost)
  end

  def initialize(@key : String, @val, @dic, @ptag : String, prio : Int32 = 3)
    @size = key.size
    @cost = MtNode.cost(@size, prio)
  end

  def to_txt(io : IO, apply_cap : Bool) : Bool
    attr = PosTag.attr_for(ptag)

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
    io << '{' << @key << '/' << @val << '/' << @ptag << '/' << @dic << '}'
  end
end

class M2::MtPair
  include MtNode
  include MtSeri

  getter head : MtNode
  getter tail : MtNode

  def initialize(@head, @tail, @ptag = tail.ptag, cost = 0, @flip = false)
    @size = @head.size &+ @tail.size
    @cost = @head.cost &+ @tail.cose &+ cost * @size # TODO: update this
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

  getter list : Array(MtNode)
  @ords : Array(Int32) | Nil = nil

  def initialize(@list : Array(MtNode), @ptag = list.last.ptag, cost = 0, @ords = nil)
    @size = list.sum(&.size)
    @cost = list.sum(&.cost) &+ cost * @size # TODO: update this
  end

  def each(&)
    if ords = @ords
      ords.each { |ord| yield @list[ord] }
    else
      @list.each { |term| yield term }
    end
  end
end

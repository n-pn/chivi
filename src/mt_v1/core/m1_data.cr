require "./mt_node/*"
require "./mt_core/*"

class M1::MtData
  getter head : MtNode
  getter tail : MtNode

  @nestable = [] of MtDefn

  def initialize(@head)
    @tail = head
    @nestable << head if can_nest?(head)
  end

  def concat(other : MtData) : self
    other_head = other.head
    other_head = other_head.succ if other_head.none?
    @tail.fix_succ!(other_head)
    @tail = other.tail
    self
  end

  def add_head(node : MtDefn)
    @head.fix_prev!(node)
    @head = node
  end

  def add_tail(node : MtDefn)
    node.fix_prev!(@tail)
    @tail = node
  end

  def add_node(node : MtDefn)
    if can_nest?(node)
      @nestable << node
      add_head(node)
      return
    elsif @head.is_a?(MtDefn) && can_meld?(node, @head)
      @head.val = join_val(node, @head)
      @head.key = node.key + head.key
      @head.idx = node.idx
      @head.dic = 0
    else
      succ = @head.succ?

      if fold = TlRule.fold_left!(right: @head, left: node)
        fold.fix_succ!(succ)
        @head = fold
      else
        add_head(node)
      end
    end
  end

  private def can_nest?(node : MtDefn)
    return unless node.puncts?

    case node.tag
    when .quoteop?, .parenop?, .brackop?, .titleop?,
         .quotecl?, .parencl?, .brackcl?, .titlecl?
      true
    else
      node.key == "\""
    end
  end

  private def can_meld?(left : MtDefn, right : MtDefn) : Bool
    case right.tag
    when .puncts? then left.tag == right.tag
    when .nhanzi?
      return false unless left.nhanzi?
      return true if right.key != "两" || left.key == "一"
      right.set!("lượng", PosTag::Qtnoun)
      false
    else
      false
    end
  end

  private def can_meld?(left : MtDefn, right : MtNode) : Bool
    false
  end

  private def join_val(left : MtNode, right : MtNode)
    return "#{left.val}#{right.val}" unless right.nhanzi?
    "#{left.val} #{fix_hanzi_val(left, right)}"
  end

  private def fix_hanzi_val(left : MtNode, right : MtNode)
    val = right.val

    case right.key[0]?
    when '五'
      left.key.ends_with?('十') ? val.sub("năm", "lăm") : val
    when '十'
      return val unless left.key =~ /[一二两三四五六七八九]$/
      val.sub("mười một", "mươi mốt").sub("mười", "mươi")
    when '零' then val.sub("linh", "lẻ")
    else          val
    end
  end

  def resolve_nested!(upper = @nestable.size - 1, lower = 0)
    i = upper

    while i > lower
      head = @nestable[i]
      char = TlRule.map_closer_char(head.val[0])

      (i - 1).downto(lower) do |j|
        tail = @nestable[j]
        next unless tail.val[0] == char

        if char == '"'
          head.set!("“", PosTag::Quoteop)
          tail.set!("”", PosTag::Quotecl)
        end

        resolve_nested!(i - 1, j + 1)
        TlRule.fold_nested!(head, tail) if tail.succ? != head

        i = j
        break
      end

      i -= 1
    end
  end

  def each
    node = @head

    while node
      yield node
      node = node.succ?
    end
  end

  def apply_cap!(cap = true) : Nil
    each { |node| cap = node.apply_cap!(cap) }
  end

  def fix_grammar!
    head = MtDefn.new("", tag: PosTag::None, dic: 0, idx: @head.idx)
    add_head(head)

    resolve_nested!(@nestable.size - 1, 0) if @nestable.size > 1
    TlRule.fix_grammar!(head)
  end

  ##########

  # include MTL::PadSpace

  def to_txt : String
    String.build { |io| to_txt(io) }
  end

  def to_txt(io : IO) : Nil
    prev = head
    prev.to_txt(io)

    while node = prev.succ?
      io << ' ' if node.space_before?(prev)
      node.to_txt(io)
      prev = node
    end
  end

  def to_mtl : String
    String.build { |io| to_mtl(io) }
  end

  def to_mtl(io : IO) : Nil
    prev = head
    prev.to_mtl(io)

    while node = prev.succ?
      io << "\t " if node.space_before?(prev)
      node.to_mtl(io)
      prev = node
    end
  end

  def inspect(io : IO) : Nil
    each do |node|
      node.inspect(io)
      io.puts
    end
  end
end

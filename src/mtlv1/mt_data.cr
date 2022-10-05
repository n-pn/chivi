require "./mt_core/*"
require "./mt_node/*"

class CV::MtData
  getter head : MtNode
  getter tail : MtNode

  @nestable = [] of MtTerm

  def initialize(@head)
    @tail = head
    @nestable << head if head.pgroup?
  end

  def concat(other : MtData) : self
    other_head = other.head
    other_head = other_head.succ if other_head.empty?
    @tail.fix_succ!(other_head)
    @tail = other.tail
    self
  end

  def add_head(node : MtTerm)
    @head.fix_prev!(node)
    @head = node
  end

  def add_tail(node : MtTerm)
    node.fix_prev!(@tail)
    @tail = node
  end

  def add_node(node : MtTerm) : Nil
    if node.pgroup?
      @nestable << node
      add_head(node)
      return
    elsif @head.is_a?(MtTerm) && can_meld?(node, @head)
      @head.val = join_val(node, head)
      @head.key = node.key + head.key
      @head.idx = node.idx
      @head.dic = 0
    else
      add_head(node)
    end
  end

  private def can_meld?(left : MtTerm, right : MtTerm) : Bool
    case right.tag
    when .puncts? then left.tag == right.tag
    when .nhanzis?
      return false unless left.nhanzis?
      return true if right.key != "两" || left.key == "一"
      right.set!("lượng", PosTag.map_quanti("两"))
      false
    else
      false
    end
  end

  private def can_meld?(left : MtTerm, right : MtNode) : Bool
    false
  end

  private def join_val(left : MtNode, right : MtNode)
    return left.val + right.val unless right.nhanzis?
    left.val + " " + fix_hanzi_val(left, right)
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
          head.set!("“", PosTag.map_punct("“"))
          tail.set!("”", PosTag.map_punct("”"))
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
    head = MtTerm.new("", tag: PosTag::Empty, dic: 0, idx: @head.idx)
    add_head(head)

    TlRule.fold_left!(@tail)
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

require "./mt_core/*"
require "./mt_node/*"

class CV::MtData
  getter head : MtNode
  getter tail : MtNode

  @nestable = [] of MtTerm

  def initialize(@head)
    @tail = head
    @nestable << head if can_nest?(head)
  end

  def concat(other : MtData) : self
    @tail.fix_succ!(other.head)
    @tail = other.tail
    self
  end

  def add_head(node : MtTerm)
    node.fix_succ!(@head)
    @head = node
  end

  def add_tail(node : MtTerm)
    node.fix_prev!(@tail)
    @tail = node
  end

  def add_node(node : MtTerm)
    if can_nest?(node)
      @nestable << node
      add_head(node)
    elsif can_meld?(node, @head)
      @head.val = join_val(node, @head)
      @head.key = node.key + @head.key
      @head.idx = node.idx
      @head.dic = 0
    elsif fold = TlRule.fold_left!(@head, node)
      fold.fix_succ!(@head)
      @head = fold
    else
      add_head(node)
    end
  end

  private def can_nest?(node : MtTerm)
    return unless node.puncts?

    case node.tag
    when .popens?, .quotecl?, .parencl?, .brackcl?, .titlecl?
      true
    else
      node.key == "\""
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  private def can_meld?(left : MtNode, right : MtNode) : Bool
    case right.tag
    when .puncts? then left.tag == right.tag
    when .litstr?
      left.tag.litstr? || left.tag.ndigit? || left.lit_str?
    when .nhanzi?
      return false unless left.nhanzi?
      return true if right.key != "两" || left.key != "一"
      right.set!("lượng", PosTag::Qtnoun)
      false
    when .ndigit?
      case left.tag
      when .ndigit?, .pdeci? then true
      when .litstr?
        right.tag = left.tag
        true
      else
        false
      end
    else
      false
    end
  end

  private def join_val(left : MtNode, right : MtNode)
    return left.val + right.val unless right.nhanzi?
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

  def resolve_nested!
    head = nil
    char = 'x'

    @nestable.reverse_each do |tail|
      if head
        next unless tail.val[0] == char

        if char == '"'
          tail.val = "“"
          head.val = "”"
        end

        TlRule.fold_nested!(head, tail) if tail.succ? != head
        head = nil
      else
        head = tail
        char = TlRule.map_closer_char(head.val[0])
      end
    end

    @nestable.clear
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

  def pad_spaces! : self
    return self unless succ = @head.succ?
    succ.pad_spaces!(@head)
    self
  end

  def fix_grammar!
    resolve_nested! if @nestable.size > 1
    TlRule.fix_grammar!(@head)
  end

  ##########

  # include MTL::PadSpace

  def to_txt : String
    String.build { |io| to_txt(io) }
  end

  def to_txt(io : IO) : Nil
    each(&.to_txt(io))
  end

  def to_mtl : String
    String.build { |io| to_mtl(io) }
  end

  def to_mtl(io : IO) : Nil
    each(&.to_mtl(io))
  end

  def inspect(io : IO) : Nil
    each(&.inspect(io))
  end
end

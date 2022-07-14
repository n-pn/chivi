require "./mt_core/*"

class CV::MtData
  getter head : MtNode
  getter tail : MtNode

  @nestable = [] of MtNode

  def initialize(@head)
    @tail = head
    @nestable << head if can_nest?(head)
  end

  def add_node(node : MtNode)
    if can_nest?(node)
      @nestable << node
    elsif can_meld?(node)
      head.dic = 0
      head.idx = node.idx
      head.key = node.key + curr.key
      head.val = join_val(node, @head)
    else
      node.fix_succ!(@head)
      @head = node
    end
  end

  private def can_nest?(node : MtNode)
    return unless node.puncts?

    case node.tag
    when .popens?, .quotecl?, .parencl?, .prackcl?, .titlecl?
      true
    else
      node.key == "\""
    end
  end

  private def can_meld?(left : MtNode, right : MtNode) : Bool
    case right.tag
    when .puncts? then left.tag == right.tag
    when .litstr?
      left.tag.litstr? || left.tag.ndigit? || left.lit_str?
    when .ndigit?
      case left.tag
      when .ndigit?, .pdeci? then true
      when .litstr?
        right.tag = left.tag
        true
      else
        false
      end
    when .nhanzi?
      return false unless left.nhanzi?
      return true unless right.key == "两"
      right.set!("lượng", PosTag::Qtnoun)
      false
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

  def resolve_nested
    tail = nil
    char = 'x'

    @nestable.reverse_each do |head|
      if tail
        next unless head.val[0] == char

        if char == '"'
          head.val = "“"
          tail.val = "”"
        end

        fold_nested!(head, tail)
        tail = nil
      else
        tail = head
        char = TlRule.map_closer_char(tail.val[0])
      end
    end
  end

  def capitalize!(cap = true) : self
    @head.apply_cap!(cap)
    self
  end

  def pad_spaces! : self
    return self unless succ = @head.succ?
    succ.pad_spaces!(@head)
    self
  end

  def fix_grammar!
    resolve_nested if @nestable.size > 1
    TlRule.fold_list!(@head, @tail)
  end

  ##########

  include MTL::PadSpace

  def to_s : String
    String.build { |io| to_s(io) }
  end

  def to_s(io : IO) : Nil
    @head.print_val(io)
  end

  def to_str : String
    String.build { |io| to_str(io) }
  end

  def to_str(io : IO) : Nil
    @head.serialize(io)
  end

  def inspect(io : IO) : Nil
    @head.deep_inspect(io)
  end
end

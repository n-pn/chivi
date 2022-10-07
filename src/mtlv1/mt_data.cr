require "./mt_node/**"
require "./mt_core/*"

class CV::MtData
  getter head : BaseTerm
  getter tail : BaseTerm
  @pgroup = [] of BaseTerm

  def initialize
    @head = BaseTerm.new("", "", tag: PosTag::Empty)
    @tail = BaseTerm.new("", "", tag: PosTag::Empty)
    @head.fix_succ!(@tail)
  end

  def concat(other : MtData) : self
    @tail.fix_succ!(other.head.succ?)
    @tail = other.tail
    self
  end

  def add_head(node : BaseTerm) : Nil
    node.fix_succ!(@head.succ)
    node.fix_prev!(@head)
  end

  def add_tail(node : BaseTerm) : Nil
    node.fix_prev!(@tail.prev)
    node.fix_succ!(@tail)
  end

  def add_node(node : BaseTerm) : Nil
    @pgroup << node if node.group_puncts?
    add_head(node)
  end

  # private def can_meld?(left : BaseTerm, right : BaseTerm) : Bool
  #   case right.tag
  #   when .punctuations? then left.tag == right.tag
  #   when .nhanzis?
  #     return false unless left.nhanzis?
  #     return true if right.key != "两" || left.key == "一"
  #     right.set!("lượng", PosTag.map_quanti("两"))
  #     false
  #   else
  #     false
  #   end
  # end

  # private def can_meld?(left : BaseTerm, right : BaseNode) : Bool
  #   false
  # end

  # private def join_val(left : BaseNode, right : BaseNode)
  #   return left.val + right.val unless right.nhanzis?
  #   left.val + " " + fix_hanzi_val(left, right)
  # end

  # private def fix_hanzi_val(left : BaseNode, right : BaseNode)
  #   val = right.val

  #   case right.key[0]?
  #   when '五'
  #     left.key.ends_with?('十') ? val.sub("năm", "lăm") : val
  #   when '十'
  #     return val unless left.key =~ /[一二两三四五六七八九]$/
  #     val.sub("mười một", "mươi mốt").sub("mười", "mươi")
  #   when '零' then val.sub("linh", "lẻ")
  #   else          val
  #   end
  # end

  def fold_groups!
    idx_upper = @pgroup.size - 1
    jdx_upper = idx_upper
    idx = 0

    while idx <= idx_upper
      pclose = @pgroup.unsafe_fetch(idx)
      idx += 1

      next unless pclose.close_puncts?
      match_tag = pclose.tag.tag - 10
      jdx = jdx_upper >= idx ? idx &- 1 : jdx_upper

      while jdx >= 0
        pstart = @pgroup.unsafe_fetch(jdx)
        jdx &-= 1

        next unless pstart.tag.tag == match_tag

        TlRule.join_group!(pclose, pstart)
        jdx_upper = jdx
      end
    end
  end

  def fix_grammar!
    MTL.fix_ptag!(@tail)
    fold_groups! if @pgroup.size > 1
    TlRule.left_join!(@tail, @head)
  end

  ##########

  def each
    node = @head

    while node = node.succ?
      break if node == @tail
      yield node
    end
  end

  def apply_cap!(cap = true) : Nil
    each { |node| cap = node.apply_cap!(cap) }
  end

  def to_txt : String
    String.build { |io| to_txt(io) }
  end

  def to_mtl : String
    String.build { |io| to_mtl(io) }
  end

  def inspect(io : IO) : Nil
    each do |node|
      node.inspect(io)
      io.puts
    end
  end
end

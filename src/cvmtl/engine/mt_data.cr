require "./mt_node/**"
require "./mt_rule/**"
require "./txt_seg"

class MT::MtData
  getter head : MonoNode
  getter tail : MonoNode
  @pgroup = [] of MonoNode

  def initialize
    @head = MonoNode.new("", "", tag: PosTag::Empty)
    @tail = MonoNode.new("", "", tag: PosTag::Empty)
    @head.fix_succ!(@tail)
  end

  def concat(other : MtData) : self
    @tail.fix_succ!(other.head.succ?)
    @tail = other.tail
    self
  end

  def add_head(node : MonoNode) : Nil
    node.fix_succ!(@head.succ)
    node.fix_prev!(@head)
  end

  def add_tail(node : MonoNode) : Nil
    node.fix_prev!(@tail.prev)
    node.fix_succ!(@tail)
  end

  def add_node(node : MonoNode) : Nil
    @pgroup << node if node.group_puncts?
    add_head(node)
  end

  def fold_groups!
    idx_upper = @pgroup.size - 1
    jdx_upper = idx_upper
    idx = 0

    while idx <= idx_upper
      pclose = @pgroup.unsafe_fetch(idx)
      idx += 1

      next unless pclose.close_puncts?
      match_tag = pclose.tag - 10
      jdx = jdx_upper >= idx ? idx &- 1 : jdx_upper

      while jdx >= 0
        pstart = @pgroup.unsafe_fetch(jdx)
        jdx &-= 1

        next unless pstart.tag == match_tag

        Core.join_group!(pclose, pstart)
        jdx_upper = jdx
      end
    end
  end

  def fix_grammar!
    fold_groups! if @pgroup.size > 1
    Core.left_join!(@tail, @head)
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

  include MtList

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

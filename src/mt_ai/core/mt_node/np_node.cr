require "./_base"

class AI::NpNode
  include MtNode

  getter orig = [] of MtNode
  getter data = [] of MtNode

  def initialize(@orig : Array(MtNode), @cpos, @_idx)
    @zstr = orig.join(&.zstr)
  end

  def translate!(dict : MtDict)
    if found = dict.get?(@zstr, @cpos)
      self.set_tl!(found)
      return
    end
  end

  @[AlwaysInline]
  def tl_phrase!(dict : MtDict)
    if found = dict.get?(@zstr, @cpos)
      self.set_tl!(found)
    else
      @orig.each(&.tl_phrase!(dict))
      fix_inner!(dict)
    end
  end

  @[AlwaysInline]
  def tl_word!(dict : MtDict) : Nil
    @orig.each(&.tl_word!(dict))
    fix_inner!(dict)
  end

  private def fix_inner!(dict : MtDict) : Nil
    @orig.reverse_each do |node|
      case node.cpos
      when "QP"
        add_head(node)
      when "DP"
        left, right = split_dp(node)
        add_head(right)
        add_node(left, at_head: left_dp?(left))
      when "CLP"
        # FIXME: split phrase if first element is CD
        add_head(node)
      when "DNP"
        add_node(node, at_head: node.pecs.prep?)
      else
        add_tail(node)
      end
    end
  end

  ###

  def add_node(node : MtNode, at_head = false) : Nil
    at_head ? add_head(node) : add_tail(node)
  end

  def add_head(node : MtNode) : Nil
    @data.unshift(node)
  end

  def add_tail(node : MtNode) : Nil
    @data.push(node)
  end

  def split_dp(node : M2Node)
    {node.left, node.right}
  end

  def split_dp(node : MtNode)
    raise "unsupported DP structure"
  end

  def left_dp?(node : M0Node)
    node.zstr.in?("")
  end

  def left_dp?(node : MtNode)
    false
  end

  ###

  def z_each(&)
    @orig.each { |node| yield node }
  end

  def v_each(&)
    list = @data.empty? ? @orig : @data
    list.each { |node| yield node }
  end

  def last
    # TODO: check for ETC node
    @orig.last
  end
end

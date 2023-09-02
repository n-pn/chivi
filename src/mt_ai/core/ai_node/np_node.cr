require "./ai_node"

class MT::NpNode
  include AiNode

  getter orig = [] of AiNode
  getter data = [] of AiNode

  def initialize(@orig : Array(AiNode), @cpos, @_idx)
    @zstr = orig.join(&.zstr)
  end

  def translate!(dict : AiDict)
    if found = dict.get?(@zstr, @cpos)
      self.set_term!(*found)
      return
    end
  end

  @[AlwaysInline]
  def tl_phrase!(dict : AiDict)
    if found = dict.get?(@zstr, @cpos)
      self.set_term!(*found)
    else
      @orig.each(&.tl_phrase!(dict))
      fix_inner!(dict)
    end
  end

  @[AlwaysInline]
  def tl_word!(dict : AiDict) : Nil
    @orig.each(&.tl_word!(dict))
    fix_inner!(dict)
  end

  private def fix_inner!(dict : AiDict) : Nil
    @orig.reverse_each do |node|
      case node.cpos
      when "QP"
        add_head(node)
      when "DP"
        if node.is_a?(M2Node)
          left, right = split_dp(node)

          add_head(right)
          add_node(left, at_head: left_dp?(left))
        else
          add_head(node)
        end
      when "CLP"
        # FIXME: split phrase if first element is CD
        add_head(node)
      when "DNP"
        pecs = node.last.term.try(&.pecs)
        add_node(node, at_head: pecs && pecs.prep?)
      else
        add_tail(node)
      end
    end
  end

  ###

  def add_node(node : AiNode, at_head = false) : Nil
    at_head ? add_head(node) : add_tail(node)
  end

  def add_head(node : AiNode) : Nil
    @data.unshift(node)
  end

  def add_tail(node : AiNode) : Nil
    @data.push(node)
  end

  def split_dp(node : M2Node)
    {node.left, node.right}
  end

  def split_dp(node : AiNode)
    pp [node]
    raise "unsupported DP structure: #{node.class}"
  end

  def left_dp?(node : M0Node)
    node.zstr.in?("")
  end

  def left_dp?(node : AiNode)
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

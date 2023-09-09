require "./ai_node"

class MT::M1Node
  include AiNode

  getter node : AiNode

  def initialize(@node, @cpos, @_idx, @attr = :none, @ipos = MtCpos[cpos])
    @zstr = node.zstr
  end

  def tl_phrase!(dict : AiDict)
    if found = dict.get?(@zstr, @ipos)
      self.set_term!(*found)
    else
      @node.tl_phrase!(dict: dict)
      @attr = @node.attr
    end
  end

  @[AlwaysInline]
  def tl_word!(dict : AiDict)
    @node.tl_word!(dict)
    @attr = @node.attr
  end

  ###

  def z_each(&)
    yield @node
  end

  def v_each(&)
    yield @node
  end

  def first
    @node
  end

  def last
    @node
  end
end

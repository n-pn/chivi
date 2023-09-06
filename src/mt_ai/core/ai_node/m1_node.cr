require "./ai_node"

class MT::M1Node
  include AiNode

  getter node : AiNode

  def initialize(@node, @cpos, @_idx, @prop = :none)
    @zstr = node.zstr
  end

  def tl_phrase!(dict : AiDict)
    if found = dict.get?(@zstr, @cpos)
      self.set_term!(*found)
    else
      @node.tl_phrase!(dict: dict)
      @prop = @node.prop
    end
  end

  @[AlwaysInline]
  def tl_word!(dict : AiDict)
    @node.tl_word!(dict)
    @prop = @node.prop
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

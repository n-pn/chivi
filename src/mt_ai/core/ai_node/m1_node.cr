require "./ai_node"

class MT::M1Node
  include AiNode

  getter node : AiNode

  def initialize(@node, @epos, @attr = :none, @_idx = 0)
    @zstr = node.zstr
  end

  def translate!(dict : AiDict, rearrange : Bool = true)
    self.tl_whole!(dict: dict)

    @node.translate!(dict: dict, rearrange: rearrange)
    @attr |= @node.attr
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

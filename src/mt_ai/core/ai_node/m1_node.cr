require "./ai_node"

class MT::M1Node
  include AiNode

  getter node : AiNode

  def initialize(@node, @cpos, @_idx, @attr = :none, @ipos = MtCpos[cpos])
    @zstr = node.zstr
  end

  def translate!(dict : AiDict, rearrange : Bool = true)
    dict.get?(@zstr, @ipos).try { |term, _dic| self.set_term!(term, _dic) }
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

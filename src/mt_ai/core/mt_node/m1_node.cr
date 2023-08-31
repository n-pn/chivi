require "./_base"

class AI::M1Node
  include MtNode

  getter node : MtNode

  def initialize(@node, @cpos, @_idx)
  end

  def z_each(&)
    yield @node
  end

  def v_each(&)
    yield @node
  end

  def last
    node
  end
end

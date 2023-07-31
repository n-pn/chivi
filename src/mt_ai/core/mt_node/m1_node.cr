require "./_base"

class AI::M1Node
  include MtNode

  getter node : MtNode

  def initialize(@node, @ptag, @attr, @_idx)
  end

  def each(&)
    yield @node
  end

  def last
    node
  end
end

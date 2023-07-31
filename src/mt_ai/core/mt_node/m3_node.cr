require "./_base"

class AI::M3Node
  include MtNode

  getter left : MtNode
  getter middle : MtNode
  getter right : MtNode

  def initialize(@left, @middle, @right, @ptag, @attr, @_idx)
  end

  def each(&)
    yield left
    yield middle
    yield right
  end

  def last
    @right
  end
end

require "./_base"

class AI::M3Node
  include MtNode

  getter left : MtNode
  getter middle : MtNode
  getter right : MtNode

  def initialize(@left, @middle, @right, @cpos, @_idx)
  end

  def z_each(&)
    yield left
    yield middle
    yield right
  end

  def v_each(&)
    yield left
    yield middle
    yield right
  end

  def last
    @right
  end
end

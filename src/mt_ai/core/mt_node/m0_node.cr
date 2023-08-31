require "./_base"

class AI::M0Node
  include MtNode

  def initialize(@zstr, @cpos, @_idx)
  end

  def translate!(dict : MtDict) : Nil
    self.set_tl!(dict.get(@zstr, @cpos))
  end

  def z_each(&)
    yield self
  end

  def v_each(&)
    yield self
  end

  def last
    self
  end

  def inspect_inner(io : IO)
    io << ' ' << @zstr
  end
end

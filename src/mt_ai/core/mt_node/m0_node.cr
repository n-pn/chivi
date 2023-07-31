require "./_base"
require "../mt_term"

class AI::M0Node
  include MtNode

  getter zstr : String

  property term : MtTerm? = nil

  def initialize(@zstr, @ptag, @attr, @_idx)
  end

  def each(&)
    yield self
  end

  def last
    self
  end

  def inspect_inner(io : IO)
    io << ' ' << @zstr
  end
end

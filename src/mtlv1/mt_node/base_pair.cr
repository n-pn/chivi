require "./base_node"

class CV::BasePair < CV::BaseNode
  include BaseExpr

  getter head : BaseNode
  getter tail : BaseNode

  def initialize(
    @head : BaseNode, @tail : BaseNode,
    @tag : PosTag = @tail.tag, @dic : Int32 = 0, @idx : Int32 = head.idx,
    flip : Bool = head.at_tail? || tail.at_head?
  )
    self.fix_prev!(head.prev?)
    self.fix_succ!(tail.succ?)
    @head, @tail = tail, head if flip
  end

  def each
    yield @head
    yield @tail
  end

  ###

  def apply_cap!(cap : Bool = true) : Bool
    cap = @head.apply_cap!(cap)
    @tail.apply_cap!(cap)
  end

  def to_txt(io : IO) : Nil
    @head.to_txt(io)
    io << ' ' unless @head.no_ws_after? || @tail.no_ws_before?
    @tail.to_txt(io)
  end

  def to_mtl(io : IO = STDOUT) : Nil
    io << '〈' << @dic << '\t'

    @head.to_mtl(io)
    io << "\t " unless @head.no_ws_after? || @tail.no_ws_before?
    @tail.to_mtl(io)

    io << '〉'
  end

  def inspect(io : IO = STDOUT, pad = 0) : Nil
    io << " " * pad << "{" << @tag.tag << "/" << @dic << "}" << '\n'

    @head.inspect(io, pad + 2)
    @tail.inspect(io, pad + 2)

    io << " " * pad << "{/" << @tag.tag << "/" << @dic << "}"
    io << '\n' if pad > 0
  end
end

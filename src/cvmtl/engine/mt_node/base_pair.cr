require "./base_node/*"

class MT::BasePair < MT::BaseNode
  include BaseExpr

  getter head : BaseNode
  getter tail : BaseNode

  def initialize(
    @head : BaseNode, @tail : BaseNode,
    @tag : MtlTag = tail.tag, @pos : MtlPos = tail.pos,
    @flip : Bool = head.at_tail? || tail.at_head?
  )
    self.fix_prev!(head.prev?)
    self.fix_succ!(tail.succ?)
  end

  def initialize(
    @head : BaseNode, @tail : BaseNode,
    tag : {MtlTag, MtlPos},
    @flip : Bool = head.at_tail? || tail.at_head?
  )
    # Log.warn { "resolve this!" }
    @tag, @pos = tag
    self.fix_prev!(head.prev?)
    self.fix_succ!(tail.succ?)
  end

  def each
    yield @tail if @flip
    yield @head
    yield @tail unless @flip
  end

  # def apply_cap!(cap : Bool = true) : Bool
  #   cap = @head.apply_cap!(cap)
  #   @tail.apply_cap!(cap)
  # end

  # def no_space_between?
  #   @head.inactive? || @head.no_ws_after? || @tail.no_ws_before? || @tail.inactive?
  # end

  # def to_txt(io : IO) : Nil
  #   @head.to_txt(io)
  #   io << ' ' unless no_space_between?
  #   @tail.to_txt(io)
  # end

  # def to_mtl(io : IO = STDOUT) : Nil
  #   io << '〈' << @dic << '\t'

  #   @head.to_mtl(io)
  #   io << "\t " unless no_space_between?
  #   @tail.to_mtl(io)

  #   io << '〉'
  # end

  # def inspect(io : IO = STDOUT, pad = 0) : Nil
  #   io << " " * pad << "{" << @tag.tag << "/" << @dic << "}" << '\n'

  #   @head.inspect(io, pad + 2)
  #   @tail.inspect(io, pad + 2)

  #   io << " " * pad << "{/" << @tag.tag << "/" << @dic << "}"
  #   io << '\n' if pad > 0
  # end
end

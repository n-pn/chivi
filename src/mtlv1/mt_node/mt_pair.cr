require "./mt_term"

class CV::MtPair < CV::MtNode
  def initialize(
    @head : MtNode, @tail : MtNode,
    @tag : PosTag = PosTag::LitBlank,
    @dic = 0, @idx = 1,
    flip = @head.at_tail?
  )
    self.fix_prev!(head.prev?)
    self.fix_succ!(tail.succ?)
    @head, @tail = tail, head if flip
  end

  private def is_empty?(node : MtNode)
    return false unless node.is_a?(MtTerm)
    node.val.empty?
  end

  def modifier?
    false
  end

  def list
    raise "invalid!"
  end

  ######

  def each
    yield @head
    yield @tail
  end

  def to_int?
    nil
  end

  def starts_with?(key : String | Char)
    {@head, @tail}.any?(&.starts_with?(key))
  end

  def ends_with?(key : String | Char)
    {@head, @tail}.any?(&.ends_with?(key))
  end

  def find_by_key(key : String | Char)
    {@head, @tail}.find(&.find_by_key(key))
  end

  ###

  def apply_cap!(cap : Bool = true) : Bool
    cap = @head.apply_cap!(cap)
    @tail.apply_cap!(cap)
  end

  def to_txt(io : IO) : Nil
    @head.to_txt(io)
    io << ' ' unless @head.no_space_after? || @tail.no_space_before?
    @tail.to_txt(io)
  end

  def to_mtl(io : IO = STDOUT) : Nil
    io << '〈' << @dic << '\t'

    @head.to_mtl(io)
    io << "\t " unless @head.no_space_after? || @tail.no_space_before?
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

require "./mt_term"

class M1::MtPair < M1::MtNode
  @[Flags]
  enum Opts
    Left # left is main
    Flip # when render, swap order of values

    NoSpace
  end

  def initialize(
    @head : MtNode,
    @tail : MtNode,
    @tag : PosTag = PosTag::Unkn,
    @dic = 0,
    @idx = 1,
    @opts = Opts::None
  )
    self.fix_prev!(head.prev?)
    self.fix_succ!(tail.succ?)
    @head, @tail = tail, head if @opts.flip?

    if is_empty?(head) || is_empty?(tail)
      @opts |= Opts::NoSpace
    end
  end

  private def is_empty?(node : MtNode)
    node.is_a?(MtDefn) && node.val.empty? || false
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
    io << ' ' unless @opts.no_space?
    @tail.to_txt(io)
  end

  def to_mtl(io : IO = STDOUT) : Nil
    io << '〈' << @dic << '\t'

    @head.to_mtl(io)
    io << "\t " unless @opts.no_space?
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

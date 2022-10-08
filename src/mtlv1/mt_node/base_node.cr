abstract class CV::BaseNode
  property key : String = ""
  property val : String = ""

  property tag : PosTag = PosTag::LitTrans
  property dic : Int32 = 0
  property idx : Int32 = 0

  property! prev : BaseNode
  property! succ : BaseNode

  forward_missing_to @tag

  def prev?
    @prev.try { |x| yield x }
  end

  def succ?
    @succ.try { |x| yield x }
  end

  def fix_prev!(prev : Nil) : Nil
    @prev = nil
  end

  def fix_prev!(@prev : BaseNode) : Nil
    prev.succ = self
  end

  def fix_succ!(succ : Nil) : Nil
    @succ = nil
  end

  def fix_succ!(@succ : BaseNode) : Nil
    succ.prev = self
  end

  @[AlwaysInline]
  def real_prev : BaseNode?
    # TODO: read beyond parenthesis
    return unless node = @prev
    node.start_puncts? || node.close_puncts? ? node.prev? : node
  end

  @[AlwaysInline]
  def real_succ : BaseNode?
    # TODO: read beyond parenthesis
    return unless node = @succ
    node.start_puncts? || node.close_puncts? ? node.succ? : node
  end

  @[AlwaysInline]
  def swap_val!
    self
  end

  def set!(@val : String) : self
    self
  end

  def set!(@tag : PosTag) : self
    self
  end

  def set!(@val : String, @tag : PosTag) : self
    self
  end

  def set_pos!(pos : MtlPos) : self
    @tag = PosTag.new(@tag.tag, pos)
    self
  end

  def set_tag!(tag : MtlTag) : self
    @tag = PosTag.new(tag, @tag.pos)
    self
  end

  abstract def to_txt(io : IO) : Nil
  abstract def to_mtl(io : IO) : Nil
  abstract def inspect(io : IO) : Nil
  abstract def apply_cap!(cap : Bool) : Bool

  def add_space?(prev = self.prev) : Bool
    !(prev.tag.inactive? || prev.tag.no_ws_after? || @tag.no_ws_before? || @tag.inactive?)
  end
end

module CV::BaseExpr
  abstract def each(&block : BaseNode -> Nil)

  def to_txt(io : IO = STDOUT) : Nil
    prev = nil

    self.each do |node|
      io << ' ' if prev && node.add_space?(prev)
      node.to_txt(io)
      prev = node unless node.tag.inactive?
    end
  end

  def apply_cap!(cap : Bool = false) : Bool
    each do |node|
      cap = node.apply_cap!(cap)
    end

    cap
  end

  def to_mtl(io : IO = STDOUT) : Nil
    io << '〈' << @dic << '\t'
    prev = nil

    self.each do |node|
      io << "\t " if prev && node.add_space?(prev)
      node.to_mtl(io)
      prev = node unless node.tag.inactive?
    end

    io << '〉'
  end

  def inspect(io : IO = STDOUT, pad = 0) : Nil
    io << " " * pad << "{" << @tag.tag.colorize.cyan << " " << @dic << "}" << '\n'
    self.each(&.inspect(io, pad + 2))
    io << " " * pad << "{/" << @tag.tag.colorize.cyan << "}"
    io << '\n' if pad > 0
  end
end
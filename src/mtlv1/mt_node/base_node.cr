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

  abstract def to_txt(io : IO)
  abstract def to_mtl(io : IO)
  abstract def inspect(io : IO)

  def add_space?(prev = self.prev) : Bool
    !(prev.tag.no_ws_after? || @tag.no_ws_before? || @tag.inactive?)
  end

  def apply_cap!(cap : Bool = false) : Bool
    case tag
    when .inactive?     then cap
    when .punctuations? then cap || @tag.cap_after?
    else
      @val = TextUtil.capitalize(@val) if cap
      false
    end
  end
end

module CV::BaseExpr
  abstract def each(&block : BaseNode -> Nil)

  def to_txt(io : IO = STDOUT) : Nil
    prev = nil

    each do |node|
      io << ' ' if prev && node.add_space?(prev)
      node.to_txt(io)
      prev = node unless node.inactive?
    end
  end

  def to_mtl(io : IO = STDOUT) : Nil
    io << '〈' << @dic << '\t'
    prev = nil

    each do |node|
      io << "\t " if prev && node.add_space?(prev)
      node.to_mtl(io)
      prev = node unless node.inactive?
    end

    io << '〉'
  end

  def inspect(io : IO = STDOUT, pad = 0) : Nil
    io << " " * pad << "{" << @tag.tag << "/" << @dic << "}" << '\n'
    self.each(&.inspect(io, pad + 2))
    io << " " * pad << "{/" << @tag.tag << "/" << @dic << "}"
    io << '\n' if pad > 0
  end
end

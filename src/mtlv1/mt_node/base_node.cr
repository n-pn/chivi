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
    # TODO: skip parenthesis
    return unless prev = @node.prev?
    prev.pstart? || prev.pclose ? prep.prev? : prev
  end

  @[AlwaysInline]
  def real_succ : BaseNode?
    # TODO: skip parenthesis
    return unless succ = @node.succ?
    succ.pstart? || succ.pclose ? prep.succ? : prev
  end

  def set!(@val : String) : self
    self
  end

  @[AlwaysInline]
  def swap_val!
    self
  end

  def set!(@tag : PosTag) : self
    self
  end

  def set!(@val : String, @tag : PosTag) : self
    self
  end

  abstract def starts_with?(key : String | Char)
  abstract def ends_with?(key : String | Char)
  abstract def find_by_key(key : String | Char)
  abstract def apply_cap!(cap : Bool)

  abstract def to_txt(io : IO)
  abstract def to_mtl(io : IO)
  abstract def inspect(io : IO)

  def space_before?(prev : Nil) : Bool
    false
  end

  def space_before?(prev : BaseNode)
    return !prev.pstart? unless prev.is_a?(MtTerm)
    return space_before?(prev.prev?) if prev.val.empty?
    !(prev.val.blank? || prev.pstart?)
  end

  def key_is?(key : String)
    false
  end

  def key_in?(*keys : String)
    false
  end
end

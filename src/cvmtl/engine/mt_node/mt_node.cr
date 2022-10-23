require "../../cv_data/pos_tag"

module MT::HasPosTag
  property pos = MtlPos::None
  property tag = MtlTag::LitBlank

  forward_missing_to @tag

  def nebulous?
    @pos.nebulous? || @tag.nebulous?
  end

  # words after this is most certainly noun words/noun phrases
  def mark_noun_after?
    @tag.quantis? || @tag.pro_split?
  end

  delegate passive?, to: @pos

  delegate mixedpos?, to: @pos
  delegate boundary?, to: @pos

  delegate cap_after?, to: @pos
  delegate no_space_l?, to: @pos
  delegate no_ws_after?, to: @pos

  delegate at_head?, to: @pos
  delegate at_tail?, to: @pos

  delegate redup?, to: @pos

  delegate aspect?, to: @pos
  delegate vauxil?, to: @pos

  delegate ktetic?, to: @pos
  delegate aspect?, to: @pos
  delegate vcompl?, to: @pos
  delegate object?, to: @pos

  delegate proper?, to: @pos
  delegate plural?, to: @pos
  delegate people?, to: @pos
  delegate locale?, to: @pos

  delegate maybe_noun?, to: @pos
  delegate maybe_verb?, to: @pos
  delegate maybe_adjt?, to: @pos
  delegate maybe_advb?, to: @pos

  delegate can_split?, to: @pos
  delegate link_verb?, to: @pos
  delegate bond_word?, to: @pos
end

abstract class MT::MtNode
  include HasPosTag

  property! prev : MtNode
  property! succ : MtNode

  def prev?
    @prev.try { |x| yield x }
  end

  def succ?
    @succ.try { |x| yield x }
  end

  def fix_prev!(prev : Nil) : Nil
    @prev = nil
  end

  def fix_prev!(@prev : MtNode) : Nil
    prev.succ = self
  end

  def fix_succ!(succ : Nil) : Nil
    @succ = nil
  end

  def fix_succ!(@succ : MtNode) : Nil
    succ.prev = self
  end

  @[AlwaysInline]
  def real_prev : MtNode?
    # TODO: read beyond parenthesis
    return unless node = @prev
    node.start_puncts? || node.close_puncts? ? node.prev? : node
  end

  @[AlwaysInline]
  def real_succ : MtNode?
    # TODO: read beyond parenthesis
    return unless node = @succ
    node.start_puncts? || node.close_puncts? ? node.succ? : node
  end

  def fix_val!
    raise "only available for MonoNode"
  end

  def set!(val : String) : self
    raise "only available for MonoNode"
  end

  def set!(@tag : MtlTag) : self
    self
  end

  def set!(@pos : MtlPos) : self
    self
  end

  abstract def to_txt(io : IO) : Nil
  abstract def to_mtl(io : IO) : Nil
  abstract def inspect(io : IO) : Nil
  abstract def apply_cap!(cap : Bool) : Bool

  def add_space?(prev = self.prev) : Bool
    !(prev.pos.no_space_r? || @pos.no_space_l?)
  end
end

module MT::MtList
  abstract def each(&block : MtNode -> Nil)

  def to_txt(io : IO = STDOUT) : Nil
    prev = nil

    self.each do |node|
      io << ' ' if prev && node.add_space?(prev)
      node.to_txt(io)
      prev = node unless node.pos.passive?
    end
  end

  def apply_cap!(cap : Bool = false) : Bool
    each do |node|
      cap = node.apply_cap!(cap)
    end

    cap
  end

  def to_mtl(io : IO = STDOUT) : Nil
    io << "〈0\t"
    prev = nil

    self.each do |node|
      io << "\t " if prev && node.add_space?(prev)
      node.to_mtl(io)
      prev = node unless node.pos.passive?
    end

    io << '〉'
  end

  def inspect(io : IO = STDOUT, pad = 0) : Nil
    io << " " * pad << "{" << @tag.colorize.cyan << " " << "}" << '\n'
    self.each(&.inspect(io, pad + 2))
    io << " " * pad << "{/" << @tag.colorize.cyan << "}"
    io << '\n' if pad > 0
  end
end

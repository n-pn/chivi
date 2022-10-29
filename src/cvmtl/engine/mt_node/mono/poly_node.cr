require "./mono_node"

class MT::PolyNode < MT::MonoNode
  getter alt : String?

  def initialize(term : MtTerm, dic = 0, idx = 0)
    super(term, dic, idx)
    @alt = term.alt_val
  end

  def fix_val!(val = @alt) : self
    @val = val if val
    self
  end

  def as_advb!(val : String? = nil)
    @val = val if val
    @tag, @pos = PosTag.cast_advb(@key)
    self
  end

  def as_adjt!(val : String? = nil)
    @val = val if val
    @tag, @pos = PosTag.cast_adjt(@key)
    self
  end

  def as_noun!(val : String? = nil)
    @val = val if val
    @tag, @pos = PosTag.cast_noun(@key)
    self
  end

  def as_verb!(val : String? = nil)
    @val = val if val
    @tag, @pos = PosTag.cast_verb(@key)
    self
  end
end

require "./_base"

class AI::M0Node
  include MtNode

  def initialize(@zstr, @cpos, @_idx)
  end

  @[AlwaysInline]
  def tl_phrase!(dict : MtDict) : Nil
    self.tl_word!(dict: dict)
  end

  @[AlwaysInline]
  def tl_word!(dict : MtDict) : Nil
    self.set_tl!(dict.get(@zstr, @cpos))
  end

  def z_each(&)
    yield self
  end

  def v_each(&)
    yield self
  end

  def last
    self
  end

  COLORS = {:light_gray, :green, :magenta, :yellow, :blue, :cyan, :red}

  def inspect_inner(io : IO)
    io << ' ' << @zstr.colorize.light_blue
    io << ' ' << @vstr.colorize(COLORS[@_dic])
  end
end

require "./ai_node"

class MT::M0Node
  include AiNode

  def initialize(@zstr, @cpos, @_idx, @attr = :none)
  end

  @[AlwaysInline]
  def tl_phrase!(dict : AiDict) : Nil
    self.tl_word!(dict: dict)
  end

  @[AlwaysInline]
  def tl_word!(dict : AiDict) : Nil
    self.set_term!(*dict.get(@zstr, @cpos))
  end

  def z_each(&)
    yield self
  end

  def v_each(&)
    yield self
  end

  def first
    self
  end

  def last
    self
  end

  COLORS = {:light_gray, :green, :magenta, :yellow, :blue, :cyan, :red}

  def inspect_inner(io : IO)
    io << ' ' << @zstr.colorize.light_blue
    io << ' ' << @vstr.colorize(COLORS[@_dic]) if @_dic >= 0
  end
end

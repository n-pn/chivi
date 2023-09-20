require "./ai_node"

class MT::M0Node
  include AiNode

  def initialize(@zstr, @epos, @attr : MtAttr = :none, @_idx : Int32 = 0)
  end

  @[AlwaysInline]
  def translate!(dict : AiDict, rearrange : Bool = true) : Nil
    self.set_term!(dict.get(@zstr, @epos))
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

  COLORS = {:green, :yellow, :blue, :red, :cyan, :magenta, :light_gray}

  def inspect_inner(io : IO)
    io << ' ' << @zstr.colorize.dark_gray
    io << ' ' << @vstr.colorize(COLORS[@dnum % 10]) if @dnum >= 0
  end
end

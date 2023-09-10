require "./ai_node"

class MT::M0Node
  include AiNode

  def initialize(@zstr, @cpos, @_idx, @attr = :none, @ipos = MtCpos[cpos])
  end

  @[AlwaysInline]
  def translate!(dict : AiDict, rearrange : Bool = true) : Nil
    self.set_term!(*dict.get(@zstr, @ipos))
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

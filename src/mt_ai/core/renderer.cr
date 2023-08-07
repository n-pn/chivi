require "../data/mt_opts"

class AI::Renderer
  @opts : MtOpts

  def initialize(@io : IO, @opts = MtOpts::Initial)
  end

  def add(vstr : String, opts : MtOpts)
    @io << ' ' unless opts.no_space?(@opts)
    @opts = opts.apply_cap(@io, vstr, prev: @opts)
  end
end

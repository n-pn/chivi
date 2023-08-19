require "../data/mt_opts"
require "../data/mt_dict"

class AI::TextRenderer
  @opts : MtOpts

  def initialize(@io : IO, @dict : MtDict, @opts = MtOpts::Initial)
  end

  def render(data : M0Node)
    if term = data.term
      vstr = term.vstr
      opts = MtOpts::None
    else
      vstr, opts = @dict.find(data.zstr, data.ptag)
    end

    @io << ' ' unless opts.no_space?(@opts)
    @opts = opts.apply_cap(@io, vstr, prev: @opts)
  end

  def render(data : MtNode)
    data.v_each { |node| render(node) }
  end
end

class AI::HtmlRenderer
  @opts : MtOpts

  def initialize(@io : IO, @dict : MtDict, @opts = MtOpts::Initial)
  end

  def render(data : M0Node)
    if term = data.term
      vstr = term.vstr
      opts = MtOpts::None
    else
      vstr, opts = @dict.find(data.zstr, data.ptag)
    end

    @io << ' ' unless opts.no_space?(@opts)
    @opts = opts.apply_cap(@io, vstr, prev: @opts)
  end

  def render(data : MtNode)
    data.v_each { |node| render(node) }
  end
end

require "../data/mt_opts"
require "../data/mt_dict"

class AI::TextRenderer
  getter? apply_cap : Bool = true
  getter? pad_space : Bool = false

  def initialize(@io : IO, @apply_cap = true, @pad_space = false)
  end

  def render(data : MtNode)
    if data._dic > 0 || data.is_a?(M0Node)
      @io << ' ' if pad_ws?(data.pecs)
      render_vstr(data.vstr, data.pecs)
    else
      data.v_each { |node| render(node) }
    end
  end

  @[AlwaysInline]
  def pad_ws?(pecs : VpPecs)
    @pad_space && !(pecs.void? || pecs.nwsl?)
  end

  private def render_vstr(vstr : String, pecs : VpPecs) : Nil
    @pad_space = !pecs.nwsr? unless pecs.void?

    case
    when pecs.void?
      # do nothing
    when pecs.capx?
      # usually for punctuation or special tokens
      @io << vstr
    when @apply_cap
      vstr.each_char_with_index { |c, i| @io << (i == 0 ? c.upcase : c) }
      @apply_cap = pecs.capr?
    else
      # do not do anything if no capitalization needed
      @io << vstr
      @apply_cap = pecs.capr?
    end
  end
end

# class AI::HtmlRenderer
#   @opts : MtOpts

#   def initialize(@io : IO, @dict : MtDict, @opts = MtOpts::Initial)
#   end

#   def render(data : M0Node)
#     if term = data.term
#       vstr = term.vstr
#       opts = MtOpts::None
#     else
#       vstr, opts = @dict.find(data.zstr, data.ptag)
#     end

#     @io << ' ' unless @opts.do_not_add_ws?(pecs)
#     @opts = opts.apply_cap(@io, vstr, prev: @opts)
#   end

#   def render(data : MtNode)
#     data.v_each { |node| render(node) }
#   end
# end

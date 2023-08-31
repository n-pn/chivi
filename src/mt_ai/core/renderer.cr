require "../data/mt_opts"
require "../data/mt_dict"

class AI::TextRenderer
  getter? apply_cap : Bool = true
  getter? pad_space : Bool = false

  def initialize(@io : IO, @apply_cap = true, @pad_space = false)
  end

  def render(data : M0Node)
    if term = data.term
      vstr = term.vstr
      pecs = VpPecs::None
    else
      vstr, pecs, _ = @dict.find(data.zstr, data.ptag)
    end

    @io << ' ' unless self.do_not_add_ws?(pecs)

    render_vstr(vstr, pecs)
    # @opts = @opts.apply_cap(@io, vstr, prev: @opts)
  end

  def render(data : MtNode)
    data.v_each { |node| render(node) }
  end

  @[AlwaysInline]
  def do_not_add_ws?(pecs : VpPecs)
    pecs.void? || pecs.nwsl? || @opts.no_ws_after? || (pecs.nwsx? && @opts.no_ws_before?)
  end

  @[AlwaysInline]
  private def merge_add_cap_after(prev : self)
    prev.add_cap_after? ? self | AddCapAfter : self
  end

  def apply_cap(vstr) : self
    case
    when self.hidden?
      flag = self.merge_add_cap_after(prev)
      prev.no_space_after? ? flag | NoSpaceAfter : flag
    when self.add_cap_passive? # usually for punctuation or special tokens
      io << str
      self.merge_add_cap_after(prev)
    when self.frozen? || !prev.add_cap_after?
      io << str
      self
    else # do not do anything if no capitalization needed
      str.each_char_with_index { |c, i| io << (i == 0 ? c.upcase : c) }
      self
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

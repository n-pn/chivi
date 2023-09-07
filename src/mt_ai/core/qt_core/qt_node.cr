# require "../shared/mt_output"
require "../../data/vi_term"

struct MT::QtNode
  getter vstr : String
  getter attr : MtAttr
  getter _len : Int32

  getter _idx : Int32
  getter _dic : Int32 = 0

  def initialize(term : MtTerm, @_idx, @_dic = 0, @_len = 0)
    @vstr = term.vstr
    @attr = term.attr
  end

  def to_txt(io : IO, cap : Bool, und : Bool)
    io << ' ' unless @attr.undent?(und)
    @attr.render_vstr(io, @vstr, cap, und)
  end

  SEP = 'ǀ'

  def to_mtl(io : IO, cap : Bool, und : Bool)
    io << '\t'
    io << ' ' unless @attr.undent?(und)
    cap, und = @attr.render_vstr(io, @vstr, cap, und)

    io << SEP << @_dic << SEP << @_idx << SEP << @_len
    {cap, und}
  end
end

# require "../shared/mt_output"
require "../../data/db_term"

struct MT::QtNode
  getter vstr : String
  getter prop : MtProp
  getter _len : Int32

  getter _idx : Int32
  getter _dic : Int32 = 0

  def initialize(term : MtTerm, @_idx, @_dic = 0, @_len = 0)
    @vstr = term.vstr
    @prop = term.prop
  end

  def to_txt(io : IO, cap : Bool, und : Bool)
    io << ' ' unless @prop.undent?(und)
    @prop.render_vstr(io, @vstr, cap, und)
  end

  SEP = 'ǀ'

  def to_mtl(io : IO, cap : Bool, und : Bool)
    io << '\t'
    io << ' ' unless @prop.undent?(und)
    cap, und = @prop.render_vstr(io, @vstr, cap, und)

    io << SEP << @_dic << SEP << @_idx << SEP << @_len
    {cap, und}
  end
end

# require "../shared/mt_output"
require "../../data/mt_term"

struct MT::QtNode
  getter vstr : String
  getter pecs : MtPecs
  getter _len : Int32

  getter _idx : Int32
  getter _dic : Int32 = 0

  def initialize(term : MtTerm, @_idx, @_dic = 0)
    @vstr = term.vstr
    @pecs = term.pecs
    @_len = term._len
  end

  def to_txt(io : IO, cap : Bool, pad : Bool)
    io << ' ' if @pecs.pad_space?(pad)
    @pecs.to_str(io, @vstr, cap, pad)
  end

  SEP = 'ǀ'

  def to_mtl(io : IO, cap : Bool, pad : Bool)
    io << '\t'
    io << ' ' if @pecs.pad_space?(pad)
    cap, pad = @pecs.to_str(io, @vstr, cap, pad)

    io << SEP << @_dic << SEP << @_idx << SEP << @_len
    {cap, pad}
  end
end

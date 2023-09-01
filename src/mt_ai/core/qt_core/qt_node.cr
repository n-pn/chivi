# require "../shared/mt_output"
require "../../data/mt_term"

struct MT::QtNode
  getter term : MtTerm

  getter _idx : Int32
  getter _dic : Int32 = 0

  def initialize(@term, @_idx, @_dic = 0)
  end

  def to_txt(io : IO, cap : Bool, pad : Bool)
    io << ' ' if term.pad_space?(pad)
    term.to_str(io, cap, pad)
  end

  SEP = 'ǀ'

  def to_mtl(io : IO, cap : Bool, pad : Bool)
    io << '\t'
    io << ' ' if term.pad_space?(pad)
    cap, pad = term.to_str(cap, pad)

    io << SEP << @_dic << SEP << @_idx << SEP << @term._len
    {cap, pad}
  end
end

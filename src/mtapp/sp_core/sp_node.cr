require "./sp_term"
require "../shared/mt_output"

struct MT::SpNode
  getter term : SpTerm
  getter _idx : Int32

  def initialize(@term, @_idx)
  end

  def to_txt(io : IO, fmt prev = FmtFlag::None) : FmtFlag
    io << ' ' unless @term.fmt.no_space?(prev)
    @term.fmt.apply_cap(io, @term.val, prev: prev)
  end

  SEP = 'ǀ'

  def to_mtl(io : IO, fmt = FmtFlag::None) : FmtFlag
    io << '\t'
    fmt = to_txt(io, fmt: fmt)
    io << SEP << @term.dic << SEP << @_idx << SEP << @term.len
    fmt
  end
end

class MT::SpData < Array(MT::SpNode)
  include MtOutput
end

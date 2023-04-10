require "../shared/*"

struct MT::QtNode
  getter val : String
  getter len : Int32

  getter idx : Int32
  getter fmt : FmtFlag

  getter cost : Int32

  INIT = new(val: "", len: 0, idx: 0, fmt: FmtFlag::Initial)

  def initialize(@val, @len, @idx, @fmt = FmtFlag::None, rank = 2)
    @cost = CwsCost.node_cost(len, rank)
  end

  def initialize(chr : Char, @idx : Int32)
    @val = chr.to_s
    @len = 1
    @fmt = FmtFlag.detect(chr)

    @cost = CwsCost.node_cost(1, 1)
  end

  def to_txt(io : IO, fmt prev = FmtFlag::None) : FmtFlag
    io << ' ' unless @fmt.no_space?(prev)
    @fmt.apply_cap(io, @val, prev: prev)
  end

  MTL_CHR = 'ǀ'

  def to_mtl(io : IO, fmt = FmtFlag::None) : FmtFlag
    io << '\t'
    fmt = to_txt(io, fmt: fmt)
    io << MTL_CHR << (@fmt.none? ? 1 : 0) << MTL_CHR << @idx << MTL_CHR << @len
    fmt
  end

  def dup!(@idx : Int32) : self
    self.dup
  end
end

class MT::QtData < Array(MT::QtNode)
  include MtOutput
end

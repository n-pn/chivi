require "./fmt_flag"

struct MT::V0Node
  getter val : String
  getter len : Int32

  getter idx : Int32
  getter fmt : FmtFlag

  INIT = new(val: "", len: 0, idx: 0, fmt: FmtFlag::Initial)

  def initialize(@val, @len, @idx, @fmt = FmtFlag::None)
  end

  def initialize(chr : Char, @idx : Int32)
    @val = chr.to_s
    @len = 1
    @fmt = FmtFlag.detect(chr)
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

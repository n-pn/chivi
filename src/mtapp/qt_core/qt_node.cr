require "../shared/*"

struct MT::QtNode
  getter zstr : String
  getter zlen : Int32
  getter vstr : String

  getter fmt : FmtFlag
  getter dic : Int32 = 0
  getter idx : Int32
  getter wgt : Int32

  def initialize(@zstr, @vstr, @dic, @idx, @fmt = FmtFlag::None, _wsr = 2)
    @zlen = zstr.size
    @wgt = CwsCost.node_cost(zlen, _wsr)
  end

  def initialize(chr : Char, @idx : Int32, @dic = 0)
    @zstr = @vstr = chr.to_s
    @zlen = 1

    @fmt = FmtFlag.detect(chr)
    @wgt = CwsCost.node_cost(1, 1)
  end

  def to_txt(io : IO, fmt prev = FmtFlag::None) : FmtFlag
    io << ' ' unless @fmt.no_space?(prev)
    @fmt.apply_cap(io, @vstr, prev: prev)
  end

  MTL_CHR = 'ǀ'

  def to_mtl(io : IO, fmt = FmtFlag::None) : FmtFlag
    io << '\t'
    fmt = to_txt(io, fmt: fmt)
    io << MTL_CHR << @dic << MTL_CHR << @idx << MTL_CHR << @zlen
    fmt
  end

  def dup!(@idx : Int32) : self
    self.dup
  end

  def inspect(io : IO)
    io << '{' << @zstr.colorize.blue << '/' << @vstr.colorize.yellow << '/' << @dic << '}'
  end
end

class MT::QtData < Array(MT::QtNode)
  include MtOutput

  def inspect(io : IO)
    each do |node|
      node.inspect(io)
      io << '\n'
    end
  end
end

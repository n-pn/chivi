# require "../shared/mt_output"
require "json"
require "../../enum/*"

struct MT::QtNode
  getter zstr : String
  getter vstr : String
  getter attr : MtAttr

  getter _idx : Int32
  getter _dic : Int32 = 0

  def initialize(@zstr, @vstr, @attr, @_idx, @_dic = 0)
  end

  def to_txt(io : IO, cap : Bool, und : Bool)
    io << ' ' unless @attr.undent?(und)
    @attr.render_vstr(io, @vstr, cap, und)
  end

  SEP = 'ǀ'

  def to_mtl(io : IO, cap : Bool, und : Bool)
    io << (@attr.undent?(und) ? '\u200b' : ' ')
    vstr, cap = @attr.fix_vstr(@vstr, cap)

    zlen = @zstr.size
    zidx = 0

    if zlen == vstr.size
      vstr.each_char do |char|
        io << '\u200b' if zidx > 0
        io << char
        zidx &+= 1
      end
    else
      vstr.split(' ') do |word|
        io << ' ' if zidx > 0
        io << word
        zidx &+= 1
      end

      (zlen &- zidx).times { io << '\u200b' }
    end

    {cap, @attr.undn?}
  end
end

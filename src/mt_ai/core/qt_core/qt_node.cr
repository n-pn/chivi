# require "../shared/mt_output"
require "json"
require "../../data/vi_term"

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
    io << '\t'
    io << ' ' unless @attr.undent?(und)
    cap, und = @attr.render_vstr(io, @vstr, cap, und)

    io << SEP << @_dic << SEP << @_idx << SEP << @_len
    {cap, und}
  end

  include JSON::Serializable

  def to_json(jb : JSON::Builder) : Nil
    jb.array do
      jb.string "_"
      jb.number @_idx
      jb.number @zstr.size

      jb.string(@attr.none? ? "" : @attr.to_str)

      jb.string @zstr
      jb.string @vstr
      jb.number @_dic
    end
  end
end

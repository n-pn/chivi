require "json"
require "./pos_tag"

class CV::VpTerm
  SPLIT = "ǀ"
  EPOCH = Time.utc(2020, 1, 1, 0, 0, 0).to_unix

  def self.mtime(rtime : Time = Time.utc) : UInt32
    (rtime.to_unix - EPOCH).//(60).to_u32
  end

  getter key : String
  getter val : Array(String)

  getter attr : String = ""
  getter rank : UInt8 = 3_u8

  getter mtime : UInt32 = 0_u32
  getter uname : String = "~"

  # auto generated fields
  getter ptag : PosTag { PosTag.from_str(@attr, @key) }
  getter point : Float64 do
    base = 1.5 + rank * 0.125
    base ** @key.size + @key.size ** base
  end
  getter is_priv : Bool { @uname[0]? == '!' }

  property _prev : VpTerm? = nil
  property _flag : UInt8 = 0_u8 # 0 => keep, 1 => overwritten, 2 => to be removed

  def initialize(@key, @val = [""], @attr = "", @rank = 3_u8,
                 @mtime = VpTerm.mtime, @uname = "~")
  end

  def initialize(cols : Array(String), dtype = 1)
    @key = cols[0]
    @val = cols.fetch(1, "").split(SPLIT)

    return if dtype < 1 # skip reading attr if dict type is lookup

    @attr = cols[2]? || ""
    @rank = cols[3]?.try(&.to_u8?) || 3_u8

    if mtime = cols[4]?.try(&.to_u32?)
      @mtime = mtime
      @uname = cols[5]? || "~"
    end
  end

  def empty? : Bool
    @val.empty? || @val.first.empty?
  end

  def to_priv!
    @uname = "!" + uname
  end

  def state : String
    self.empty? ? "Xoá" : (self._prev ? "Sửa" : "Thêm")
  end

  def to_s(io : IO, dtype = 1) : Nil
    io << key << '\t'
    @val.join(io, SPLIT)

    return if dtype < 1 # skip printing if dict type is lookup
    io << '\t' << @attr << '\t' << (@rank == 3_u8 ? "" : @rank)

    return if @mtime <= 0
    io << '\t' << @mtime << '\t' << @uname
  end

  def inspect(io : IO) : Nil
    io << '[' << key << '/'
    @val.join(io, ',')

    io << '/' << @attr << ' '
    io << @rank == 3 ? "" : @rank

    if @mtime > 0
      io << '/' << @mtime << '/' << @uname
    end

    io << ']'
  end

  def to_json(jb : JSON::Builder)
    jb.object do
      jb.field "key", @key
      jb.field "val", @val

      jb.field "ptag", ptag.to_str
      jb.field "rank", rank

      jb.field "mtime", @mtime * 60 + EPOCH
      jb.field "uname", @uname

      jb.field "state", self.state
      jb.field "_flag", @_flag
    end
  end
end

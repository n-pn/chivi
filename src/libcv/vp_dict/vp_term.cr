require "json"
require "./pos_tag"

class CV::VpTerm
  SPLIT = "ǀ"
  EPOCH = Time.utc(2020, 1, 1, 0, 0, 0).to_unix

  def self.mtime(rtime : Time = Time.utc) : Int32
    (rtime.to_unix - EPOCH).//(60).to_i
  end

  getter key : String
  getter val : Array(String)

  getter attr : String = ""
  getter rank : UInt8 = 3_u8

  getter mtime : Int32 = 0
  getter uname : String = "~"

  # auto generated fields
  property ptag : PosTag { PosTag.parse(@attr, @key) }

  SCORES = {
    3, 6, 9,
    14, 18, 26,
    25, 31, 40,
    40, 45, 55,
    58, 66, 78,
  }

  getter point : Int32 do
    size = @key.size  # cache result because String#size is O(n) for utf8 string
    rank = @rank &- 2 # rank nows is 2 3 4
    SCORES[(size &- 1) &* 3 &+ rank]? || size &* (rank &* 2 &+ 7) &* 2
  end

  getter is_priv : Bool { @uname[0]? == '!' }

  property _prev : VpTerm? = nil
  property _flag : UInt8 = 0_u8 # 0 => keep, 1 => overwritten, 2 => to be removed

  def initialize(@key, @val = [""], @attr = "", @rank = 3_u8,
                 @mtime = VpTerm.mtime, @uname = "~")
  end

  def initialize(cols : Array(String), dtype = 0)
    @key = cols[0]
    @val = cols.fetch(1, "").split(SPLIT)

    return if dtype < 0 # skip reading attr if dict type is lookup

    @attr = cols[2]? || ""
    @rank = cols[3]?.try(&.to_u8?) || 3_u8
    @rank = 2 if @rank < 2

    if mtime = cols[4]?.try(&.to_i?)
      @mtime = mtime
      @uname = cols[5]? || "~"
    end
  end

  def deleted?
    @_flag > 0_i8
  end

  def force_fix!(@val, @attr = "", @mtime = @mtime + 1, @_flag = 0_u8)
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

  def to_s(io : IO, dtype = 0) : Nil
    io << key << '\t'
    @val.join(io, SPLIT)

    return if dtype < 0 # skip printing if dict type is lookup
    io << '\t' << @attr << '\t' << (@rank == 3_u8 ? "" : @rank)
    io << '\t' << @mtime << '\t' << @uname if @mtime > 0
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

  def utime : Int64
    EPOCH &+ @mtime &* 60
  end

  def to_json(jb : JSON::Builder)
    jb.object do
      jb.field "key", @key
      jb.field "val", @val

      jb.field "ptag", ptag.to_str
      jb.field "rank", rank

      jb.field "mtime", self.utime
      jb.field "uname", @uname

      jb.field "state", self.state
      jb.field "_flag", @_flag
    end
  end
end

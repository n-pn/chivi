require "json"

require "./pos_tag"

class CV::VpTerm
  SPLIT = "ǀ"
  EPOCH = Time.utc(2020, 1, 1, 0, 0, 0).to_unix

  def self.mtime(rtime : Time = Time.utc) : Int32
    (rtime.to_unix - EPOCH).//(60).to_i
  end

  WORTH = {
    0, 3, 6, 9,
    0, 14, 18, 26,
    0, 25, 31, 40,
    0, 40, 45, 55,
    0, 58, 66, 78,
  }

  def self.worth(size : Int32, rank : Int8 = 0) : Int32
    WORTH[(size &- 1) &* 4 &+ rank]? || size &* (rank &* 2 &+ 7) &* 2
  end

  def self.parse_rank(str : String?)
    case str
    when "x", "0" then 0_i8
    when "v", "2" then 1_i8
    when "^", "4" then 3_i8
    else               2_i8
    end
  end

  getter key : String
  property val : Array(String)

  property attr : String = ""
  property rank : Int8 = 2_i8

  getter mtime : Int32 = 0
  getter uname : String = "~"

  # auto generated fields
  getter ptag : PosTag { PosTag.parse(@attr, @key) }
  getter point : Int32 { VpTerm.worth(@key.size, @rank) }

  getter is_priv : Bool { @uname[0]? == '!' }

  property _prev : VpTerm? = nil
  property _flag : UInt8 = 0_u8 # 0 => keep, 1 => overwritten, 2 => to be removed

  def initialize(@key, @val = [""], @attr = "", @rank = 2_i8,
                 @mtime = VpTerm.mtime, @uname = "~")
  end

  def initialize(cols : Array(String), dtype = 0)
    @key = cols[0]
    @val = cols.fetch(1, "").split(SPLIT)

    @attr = cols[2]? || ""
    @rank = VpTerm.parse_rank(cols[3]?)
    if mtime = cols[4]?.try(&.to_i?)
      @mtime = mtime
      @uname = cols[5]? || "~"
    end
  end

  def deleted?
    @_flag > 0_u8 || @val.empty? || @val.first.empty?
  end

  def force_fix!(@val, @attr = "", @mtime = @mtime &+ 1, @_flag = 0_u8)
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
    io << '\t' << @attr << '\t' << {"x", "v", "", "^"}[@rank]
    io << '\t' << @mtime << '\t' << @uname if @mtime > 0
  end

  def inspect(io : IO) : Nil
    io << '[' << key << '/'
    @val.join(io, ',')

    io << '/' << @attr << ' '

    io << @rank == 2_i8 ? "" : @rank

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

      jb.field "ptag", @attr
      jb.field "rank", @rank

      jb.field "mtime", self.utime
      jb.field "uname", @uname

      jb.field "state", self.state
      jb.field "_flag", @_flag
    end
  end
end

require "json"
require "../mt_node"

class MtlV2::V2Term
  SPLIT = "ǀ"
  EPOCH = Time.utc(2020, 1, 1, 0, 0, 0).to_unix

  def self.mtime(rtime : Time = Time.utc) : Int32
    (rtime.to_unix - EPOCH).//(60).to_i
  end

  getter key : String
  getter vals : Array(String)
  getter tags : Array(String)

  # auto generated fields
  getter node : MTL::BaseWord { MTL.from_term(self) }

  getter rank : Int8 = 3_i8

  getter mtime : Int32 = 0
  getter uname : String = "~"

  WEIGHS = {
    3, 6, 9,
    14, 18, 26,
    25, 31, 40,
    40, 45, 55,
    58, 66, 78,
  }

  getter worth : Int32 do
    rank = @rank &- 2 # legacy rank is 1 2 3 4
    return 0 if rank < 0

    size = @key.size # cache result because String#size is O(n) for utf8 string
    WEIGHS[(size &- 1) &* 3 &+ rank]? || size &* (rank &* 2 &+ 7) &* 2
  end

  getter is_priv : Bool { @uname[0]? == '!' }

  property _prev : V2Term? = nil
  property _flag : UInt8 = 0_u8 # 0 => keep, 1 => overwritten, 2 => to be removed

  def initialize(@key, @vals = [""], @tags = [""], @rank = 3_i8,
                 @mtime = V2Term.mtime, @uname = "~")
  end

  def initialize(cols : Array(String), dtype = 0)
    @key = cols[0]

    @vals = cols.fetch(1, "").split(SPLIT)
    @tags = cols[2]?.try(&.split(" ")) || [""]

    @rank = cols[3]?.try(&.to_i8?) || 3_i8
    @rank = 2_i8 if @rank < 2

    if mtime = cols[4]?.try(&.to_i?)
      @mtime = mtime
      @uname = cols[5]? || "~"
    end
  end

  def deleted?
    @_flag > 0_u8 || @vals.empty? || @vals.first.empty?
  end

  def force_fix!(@vals, @attr = "", @mtime = @mtime &+ 1, @_flag = 0_u8)
  end

  def empty? : Bool
    @vals.empty? || @vals.first.empty?
  end

  def to_priv!
    @uname = "!" + uname
  end

  def to_s(io : IO, dtype = 0) : Nil
    io << key << '\t'
    @vals.join(io, SPLIT)

    io << '\t' << @tags.join(' ') << '\t'
    io << (@rank == 3_i8 ? "" : @rank)

    io << '\t' << @mtime << '\t' << @uname if @mtime > 0
  end

  def inspect(io : IO) : Nil
    io << '[' << key << '/' << @vals.join(';') << '/' << @tags.join(':')
    io << ' ' << @rank == 3 ? "" : @rank
    io << '/' << @mtime << '/' << @uname if @mtime > 0
    io << ']'
  end

  def utime : Int64
    EPOCH &+ @mtime &* 60
  end

  def to_json(jb : JSON::Builder)
    jb.object do
      jb.field "key", @key

      jb.field "vals", @vals
      jb.field "tags", @tags

      jb.field "rank", @rank

      jb.field "mtime", self.utime
      jb.field "uname", @uname

      jb.field "state", self.empty? ? "Xoá" : (self._prev ? "Sửa" : "Thêm")
      jb.field "_flag", @_flag
    end
  end
end

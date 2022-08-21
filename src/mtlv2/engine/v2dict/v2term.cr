require "json"
require "../mt_node"

class MtlV2::V2Term
  SPLIT = "ǀ"
  EPOCH = Time.utc(2020, 1, 1, 0, 0, 0).to_unix

  def self.mtime(rtime : Time = Time.utc) : Int32
    (rtime.to_unix - EPOCH).//(60).to_i
  end

  def self.parse_prio(str : String?)
    case str
    when "x", "0" then 0_i8
    when "v", "2" then 1_i8
    when "^", "4" then 3_i8
    else               2_i8
    end
  end

  WORTH = {
    0, 3, 6, 9,
    0, 14, 18, 26,
    0, 25, 31, 40,
    0, 40, 45, 55,
    0, 58, 66, 78,
  }

  def self.fare(size : Int32, prio : Int8 = 0) : Int32
    WORTH[(size &- 1) &* 4 &+ prio]? || size &* (prio &* 2 &+ 7) &* 2
  end

  getter key : String
  getter vals : Array(String)
  getter tags : Array(String)
  getter prio : Int8 = 3_i8

  getter mtime : Int32 = 0
  getter uname : String = "~"

  # auto generated fields
  getter fare : Int32 { V2Term.fare(@key.size, @prio) }
  getter node : MTL::BaseWord { MTL.from_term(self, 0) }

  # flags:
  # 0 => active
  # 1 => mark as deleted
  # 2 => overwritten
  # 3 => mark as duplicate
  property _flag : UInt8 = 0_u8

  # modes:
  # 0 => normal
  # 1 => draft
  # 2 => private
  property _mode : UInt8 = 0_u8

  # previous entry that this one overwrite
  property _prev : V2Term? = nil

  def initialize(@key, @vals = [""], @tags = [""], @prio = 2_i8,
                 @mtime = V2Term.mtime, @uname = "~")
    @_flag = @vals.first.empty? ? 1_u8 : 0_u8
  end

  def initialize(cols : Array(String), dtype = 0)
    @key = cols[0]

    @vals = cols[1]?.try(&.split(SPLIT)) || [""]
    @tags = cols[2]?.try(&.split(' ')) || [""]
    @prio = V2Term.parse_prio(cols[3]?)

    @_flag = @vals.first.empty? ? 1_u8 : 0_u8

    return unless mtime = cols[4]?

    @mtime = mtime.to_i
    @uname = cols[5]? || "~"

    case @uname[0]?
    when '!'
      @_mode = 2_u8
      @uname = @uname[1..]
    when '~'
      @_mode = 1_u8
      @uname = @uname[1..]
    else
      @_mode = 0_u8
    end
  end

  def deleted?
    @_flag > 0_u8 || @vals.empty? || @vals.first.empty?
  end

  def force_fix!(@vals, @attr = "", @mtime = @mtime &+ 1, @_flag = 0_u8)
  end

  @[AlwaysInline]
  def deleted?
    @_flag > 0_u8
  end

  @[AlwaysInline]
  def prio_str
    {"x", "v", "", "^"}[@prio]
  end

  @[AlwaysInline]
  def mode_str
    {"", "~", "!"}[@_mode]
  end

  @[AlwaysInline]
  def temp?
    @_mode == 1_u8
  end

  @[AlwaysInline]
  def priv?
    @_mode == 2_u8
  end

  def state : String
    @_flag == 1_i8 ? "Xoá" : (self._prev ? "Sửa" : "Thêm")
  end

  def to_s(io : IO, dtype = 0) : Nil
    io << key << '\t' << @vals.join(SPLIT)
    io << '\t' << @tags.join(" ") << '\t' << prio_str
    return unless @mtime > 0 || @_mode > 0
    io << '\t' << @mtime << '\t' << mode_str << @uname
  end

  def inspect(io : IO) : Nil
    io << '[' << key << '/' << @vals.join(", ")
    io << '/' << @tags.join(" ") << "/" << prio_str
    io << '/' << @mtime << '/' << mode_str << @uname if @mtime > 0
    io << ']'
  end

  @[AlwaysInline]
  def utime : Int64
    EPOCH &+ @mtime &* 60
  end

  def to_json(jb : JSON::Builder)
    jb.object do
      jb.field "key", @key

      jb.field "vals", @vals
      jb.field "tags", @tags

      jb.field "prio", self.prio_str

      jb.field "mtime", self.utime
      jb.field "uname", @uname

      jb.field "_flag", @_flag
      jb.field "_mode", @_mode
      jb.field "state", self.state
    end
  end

  # checking if new term can overwrite current term
  def newer?(prev : self | Nil) : Bool
    return true unless prev
    time_diff = self.mtime &- prev.mtime

    # do not record if self is outdated
    return false if time_diff < 0

    if self.uname == prev.uname && time_diff <= 5
      prev._flag = 3_u8
      self._prev = prev._prev
    elsif prev._flag == 1_u8
      prev._flag = 2_u8
      self._prev = prev._prev
    else
      prev._flag = 2_u8
      self._prev = prev
    end

    true
  end
end

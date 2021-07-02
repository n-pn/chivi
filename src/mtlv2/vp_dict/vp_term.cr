require "json"
require "./pos_tag"

class CV::VpTerm
  SEP = "ǀ"

  EPOCH = Time.utc(2020, 1, 1, 7, 0, 0)

  getter key : String
  getter val : Array(String)

  getter ext : String = ""
  getter wgt : String { @ext.split(" ").last.try(&.to_i?) || 3 }
  getter tag : PosTag { PosTag.from_str(@ext.split(" ").first) }

  getter mtime : Int32 = 0
  getter uname : String = "."
  getter privi : Int32 = 1

  getter dtype : Int32 = 1
  getter point : Float64 { calc_point }
  getter rtime : Time { EPOCH + @mtime.minutes }

  property _prev : VpTerm? = nil

  def initialize(cols : Array(String), @dtype = 2, @privi = 2)
    @key = cols[0]
    @val = cols.fetch(1, "").split(SEP)

    return if @dtype < 2 # skip reading ext if dict type is lookup
    @ext = cols[2]? || ""

    return unless mtime = cols[3]?.try(&.to_i?)
    @mtime = mtime

    @uname = cols[4]? || "."
    @privi = cols[5]?.try(&.to_i?) || @privi
  end

  def initialize(@key,
                 @val = [""], @ext = "",
                 @mtime = VpTerm.mtime, @uname = ".", @privi = 1,
                 @dtype = 2)
  end

  def set_ext(@ext : String, @tag = nil, @wgt = nil)
    @point = nil # need to calculate weight again
  end

  def set_ext(tag : PosTag = self.tag, wgt : Int32 = self.wgt)
    ext = wgt != 3 ? "#{tag.to_str} #{wgt}" : tag.to_str
    set_ext(ext, tag, wgt)
  end

  private def calc_point
    base = 1.25 + wgt * 0.125 + @dtype * 0.125
    base ** @key.size + @key.size ** base
  end

  def empty?
    @val.empty? || @val.first.empty?
  end

  def beats?(other : self)
    if @uname == other.uname || @privi == other.privi
      @mtime >= other.mtime
    else
      @privi > other.privi
    end
  end

  def to_s(io : IO) : Nil
    io << key << '\t'
    @val.join(io, SEP)

    return if @dtype < 2 # skip for lookup dicts
    io << '\t' << @ext

    return if @mtime <= 0 # skip if no user activity
    io << '\t' << @mtime << '\t' << @uname << '\t' << @privi
  end

  def to_json(jb : JSON::Builder)
    jb.object do
      jb.field "key", @key
      jb.field "val", @val
      jb.field "ext", @ext

      jb.field "mtime", rtime.to_unix_ms
      jb.field "uname", @uname
      jb.field "privi", @privi

      jb.field "state", empty? ? "Xoá" : (@_prev ? "Sửa" : "Thêm")
    end
  end

  def self.mtime(rtime : Time = Time.utc)
    (rtime - EPOCH).total_minutes.round.to_i
  end
end

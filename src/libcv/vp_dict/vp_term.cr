require "json"
require "./pos_tag"

class CV::VpTerm
  SEP = "ǀ"

  EPOCH = Time.utc(2020, 1, 1, 0, 0, 0)

  getter key : String
  getter val : Array(String)

  getter attr : String = ""
  getter ptag : PosTag { PosTag.from_str(@attr.split(" ").first) }
  getter rank : Int32 = 3

  getter mtime : Int32 = 0
  getter uname : String = "_"

  getter dtype : Int32 = 1
  getter point : Float64 do
    base = 1.5 + rank * 0.125
    base ** @key.size + @key.size ** base
  end

  getter rtime : Time { EPOCH + @mtime.minutes }

  property _prev : VpTerm? = nil

  def initialize(cols : Array(String), @dtype = 2)
    @key = cols[0]
    @val = cols.fetch(1, "").split(SEP)

    return if @dtype < 1 # skip reading attr if dict type is lookup

    @attr = cols[2]? || ""
    @rank = cols[3]?.try(&.to_i?) || 3

    if mtime = cols[4]?.try(&.to_i?)
      @mtime = mtime
      @uname = cols[5]? || "_"
    end
  end

  def initialize(@key,
                 @val = [""], @attr = "", @rank = 3,
                 @mtime = VpTerm.mtime, @uname = "_",
                 @dtype = 2)
  end

  def set_attr(@attr : String, @ptag = nil)
  end

  def set_rank(@rank : Int32)
    @point = nil
  end

  def empty?
    @val.empty? || @val.first.empty?
  end

  def to_s(io : IO) : Nil
    io << key << '\t'
    @val.join(io, SEP)

    return if @dtype < 1 # skip printing if dict type is lookup
    io << '\t' << @attr << '\t' << (@rank == 3 ? "" : @rank)

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

      jb.field "mtime", rtime.to_unix
      jb.field "uname", @uname

      jb.field "state", empty? ? "Xoá" : (@_prev ? "Sửa" : "Thêm")
    end
  end

  def self.mtime(rtime : Time = Time.utc)
    (rtime - EPOCH).total_minutes.round.to_i
  end
end

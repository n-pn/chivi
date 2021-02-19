require "json"

class CV::VpTerm
  SEP = "ǀ"

  EPOCH = Time.utc(2020, 1, 1)

  getter key : String
  getter vals : Array(String)

  property prio : Int8 = 1_i8
  property attr : Int8 = 0_i8

  getter mtime : Int32 = 0
  getter rtime : Time { EPOCH + @mtime.minutes }

  getter uname : String = "_"
  getter power : Int8 = 1_i8

  getter dtype : Int8 = 1_i8
  getter point : Float64 { calc_point }

  property _prev : VpTerm? = nil

  def self.parse_prio(attrs : String)
    case attrs[0]?
    when 'H' then 2_i8
    when 'L' then 0_i8
    else          1_i8
    end
  end

  def self.parse_attr(attrs : String)
    res = 0_i8
    res += 1_i8 if attrs.includes?('N')
    res += 2_i8 if attrs.includes?('V')
    res += 4_i8 if attrs.includes?('A')

    res
  end

  def initialize(cols : Array(String), @dtype = 2_i8, @power = 2_i8)
    @key = cols[0]
    @vals = cols[1]?.try(&.split(SEP)) || [""]

    return if @dtype < 2 # skip for lookup dicts

    if attrs = cols[2]?
      @prio = VpTerm.parse_prio(attrs)
      @attr = VpTerm.parse_attr(attrs)
    end

    return unless mtime = cols[3]?.try(&.to_i?)
    @mtime = mtime

    @uname = cols[4]? || "_"
    @power = cols[5]?.try(&.to_i8?) || @power
  end

  def initialize(@key,
                 @vals = [""], @prio = 1_i8, @attr = 0_i8,
                 @mtime = VpTerm.mtime, @uname = "_", @power = 1_i8,
                 @dtype = 2_i8)
  end

  private def calc_point
    # add 0.25 for medium priority, 0.5 for high priority
    # add 0.4 for regular, 0.6 for unique
    base = 1.4 + @prio * 0.25 + @dtype * 0.2
    base ** @key.size + @key.size ** base
  end

  def empty?
    @vals.empty? || @vals.first.empty?
  end

  def beats?(other : self)
    return @mtime >= other.mtime if @uname == other.uname || @power == other.power
    @power > other.power
  end

  def to_s
    String.build { |io| to_s(io) }
  end

  def to_s(io : IO) : Nil
    io << key << '\t'
    @vals.join(io, SEP)

    return if @dtype < 2 # skip for lookup dicts

    io << '\t'

    case @prio
    when 2_i8 then io << 'H'
    when 0_i8 then io << 'L'
    end

    io << 'N' if @attr & 1 != 0
    io << 'V' if @attr & 2 != 0
    io << 'A' if @attr & 4 != 0

    return if @mtime <= 0 # skip if no user activity
    io << '\t' << @mtime << '\t' << @uname << '\t' << @power
  end

  def to_json(json : JSON::Builder)
    json.object do
      json.field "key", @key
      json.field "vals", @vals

      json.field "prio", @prio
      json.field "attr", @attr

      json.field "mtime", rtime.to_unix_ms
      json.field "uname", @uname
      json.field "power", @power

      json.field "state", empty? ? "Xoá" : (@_prev ? "Sửa" : "Thêm")
    end
  end

  def rtime
    EPOCH + @mtime.minutes
  end

  def self.mtime(time : Time = Time.utc)
    (time - EPOCH).total_minutes.round.to_i
  end
end

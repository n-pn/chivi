require "json"

class CV::Vterm
  SEP = "ǀ"

  EPOCH = Time.utc(2020, 1, 1)

  getter key : String
  getter vals : Array(String)

  property prio : Int32 = 1
  property attr : Int32 = 0

  getter mtime : Int32 = 0
  getter rtime : Time { EPOCH + @mtime.minutes }

  getter uname : String = "_"
  getter power : Int32 = 1

  getter dtype : Int32 = 1
  getter point : Float64 { calc_point }

  property _prev : Vterm? = nil

  def self.parse_prio(attrs : String)
    case attrs[0]?
    when 'H' then 2
    when 'L' then 0
    else          1
    end
  end

  def self.parse_attr(attrs : String)
    res = 0
    res += 1 if attrs.includes?('N')
    res += 2 if attrs.includes?('V')
    res += 4 if attrs.includes?('A')

    res
  end

  def initialize(cols : Array(String), @dtype = 2, @power = 2)
    @key = cols[0]
    @vals = cols[1]?.try(&.split(SEP)) || [""]

    return if @dtype < 2 # skip for lookup dicts

    if attrs = cols[2]?
      @prio = Vterm.parse_prio(attrs)
      @attr = Vterm.parse_attr(attrs)
    end

    return unless mtime = cols[3]?.try(&.to_i?)
    @mtime = mtime

    @uname = cols[4]? || "_"
    @power = cols[5]?.try(&.to_i?) || @power
  end

  def initialize(@key,
                 @vals = [""], @prio = 1, @attr = 0,
                 @mtime = Vterm.mtime, @uname = "_", @power = 1,
                 @dtype = 2)
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
    when 2 then io << 'H'
    when 0 then io << 'L'
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

  def set_attr!(type : Symbol) : Nil
    case type
    when :noun then @attr |= 1
    when :verb then @attr |= 2
    when :adje then @attr |= 4
    end
  end

  def clear_attr!(type : Symbol) : Nil
    case type
    when :noun then @attr &= ~1
    when :verb then @attr &= ~2
    when :adje then @attr &= ~4
    end
  end
end

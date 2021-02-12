require "json"

class CV::VpTerm
  SEP = "ǀ"

  EPOCH = Time.utc(2020, 1, 1)
  getter rtime : Time { EPOCH + @mtime.minutes }

  getter key : String
  getter key : String

  getter vals : Array(String)
  getter attr : String = ""
  getter prio : Char = 'M'

  getter mtime : Int32 = 0
  getter uname : String = "_"
  getter power : Int32 = 1

  getter dtype : Int32 = 1
  getter point : Float64 { calc_point }

  def initialize(cols : Array(String), @dtype = 2, p_min = 2)
    @key = cols[0]
    @vals = cols.fetch(1, "").split(SEP)

    return if @dtype < 2 # skip for lookup dicts

    @attr = cols[2]? || "---"
    @prio = cols[3]?.try(&.[0]?) || 'M'

    return unless mtime = cols[4]?.try(&.to_i?)
    @mtime = mtime

    @uname = cols[5]? || "_"
    @power = cols[6]?.try(&.to_i?) || p_min
  end

  def initialize(@key,
                 @vals = [""], @attr = "---", @prio = 'M',
                 @mtime = VpTerm.mtime, @uname = "_", @power = 1,
                 @dtype = 2)
  end

  private def calc_point
    base = base_point + @dtype * 0.2 # => add 0.4 for regular, 0.6 for unique
    base ** @key.size + @key.size ** base
  end

  private def base_point
    case @prio
    when 'H' then 1.5 # highest priority
    when 'L' then 1   # lowest priority
    else          1.25
    end
  end

  def empty?
    @vals.empty? || @vals.first.empty?
  end

  def beats?(other : self)
    return @power >= other.power if @uname == other.uname
    return @mtime >= other.mtime if @power == other.power
    @power > other.power
  end

  def to_s
    String.build { |io| to_s(io) }
  end

  def to_s(io : IO) : Nil
    io << key << '\t'
    @vals.join(io, SEP)

    return if @dtype < 2 # skip for lookup dicts
    {@attr, @prio}.join(io, '\t')

    return if @mtime <= 0 # skip if no user activity
    {@mtime, @uname, @power}.join(io, '\t')
  end

  def to_json(json : JSON::Builder)
    json.object do
      json.field key, @key

      json.field vals, @vals
      json.field attr, @attr
      json.field prio, @prio.to_s

      json.field mtime, rtime.to_unix_ms
      json.field uname, @uname
      json.field power, @power
    end
  end

  def rtime
    EPOCH + @mtime.minutes
  end

  def self.mtime(time : Time = Time.utc)
    (time - EPOCH).total_minutes.round.to_i
  end
end

class CV::VpEmend
  EPOCH = Time.utc(2020, 1, 1)

  getter mtime : Int32  # modification time
  getter uname : String # username
  getter power : Int32  # permission lock
  getter rtime : Time { EPOCH + @mtime.minutes }

  def initialize(mtime : Int32? = nil, @uname = "_", @power = 0)
    @mtime = mtime || (Time.utc - EPOCH).total_minutes.round.to_i
  end

  def newer?(other : Nil) : Bool
    true
  end

  def newer?(other : self) : Bool
    return @mtime >= other.mtime if @power == other.power
    @power > other.power
  end

  def to_s(io : IO)
    {@mtime, @uname, @power}.join(io, '\t')
  end

  #####################

  def self.from(cols : Array(String), p_min : Int32 = 0)
    return unless mtime = cols[3]?.try(&.to_i?)

    uname = cols[4]? || "_"
    power = cols[5]?.try(&.to_i?) || p_min

    new(mtime, uname, power)
  end
end

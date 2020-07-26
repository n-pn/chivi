class EditData
  EPOCH = Time.utc(2020, 1, 1)
  SEP_0 = "ǁ"

  def self.mtime(time = Time.utc)
    (time - EPOCH).total_minutes.to_i
  end

  def self.parse!(line : String)
    cols = line.split(SEP_0)

    mtime, uname, power, key = cols
    vals = cols.fetch(4, "")
    extra = cols.fetch(5, "")

    new(mtime.to_i, uname, power.to_i, key, vals, extra)
  end

  getter mtime : Int32  # time by total minutes since the EPOCH
  getter uname : String # user handle dname
  getter power : Int32  # entry lock level

  getter key : String
  getter vals : String
  getter extra : String

  def initialize(@mtime, @uname, @power, @key, @vals = "", @extra = "")
  end

  def to_s
    String.build { |io| to_s(io) }
  end

  def to_s(io : IO)
    {@mtime, @uname, @power, @key, @vals, @extra}.join(io, SEP_0)
  end

  def puts(io : IO)
    to_s(io)
    io << "\n"
  end

  def better_than?(other : Edit)
    return @mtime >= other.mtime if @power == other.power
    @power > other.power
  end
end

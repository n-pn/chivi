class Libcv::DictEdit
  EPOCH = Time.utc(2020, 1, 1)
  SEP_0 = "ǁ"

  def self.mtime(time = Time.utc)
    (time - EPOCH).total_minutes.to_i
  end

  def self.parse!(line : String)
    cols = line.split(SEP_0)

    key = cols[0]
    val = cols[1]? || ""

    mtime = cols[2]?.try(&.to_i) || 0
    uname = cols[3]? || "Guest"
    power = cols[4]?.try(&.to_i) || 1

    new(key, val, mtime, uname, power)
  end

  getter key : String
  getter val : String

  getter mtime : Int32  # time by total minutes since `EPOCH`
  getter uname : String # user handle dname
  getter power : Int32  # entry lock level

  def initialize(@key, @val = "", @mtime = DictEdit.mtime, @uname = "Guest", @power = 1)
  end

  def to_s
    String.build { |io| to_s(io) }
  end

  def to_s(io : IO)
    {@key, @val, @mtime, @uname, @power}.join(io, SEP_0)
  end

  def puts(io : IO)
    to_s(io)
    io << "\n"
  end

  def eql?(other : self)
    return false if @val != other.val
    @uname == other.uname
  end

  def utime
    (EPOCH + mtime.minutes).to_unix_ms
  end

  def prevail?(other : self)
    case @power <=> other.power
    when 1 then true
    when 0 then @mtime >= other.mtime
    else        false
    end
  end
end

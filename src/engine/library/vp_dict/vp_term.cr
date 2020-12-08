class Chivi::VpTerm
  SEP_0 = "ǀ"
  EPOCH = Time.utc(2020, 1, 1)

  def self.parse(line : String, dtype : Int32 = 0, dlock : Int32 = 1)
    cols = line.split('\t')

    key = cols[0]
    vals = (cols[1]? || "").split(SEP_0)
    attr = cols[2]? || ""

    new(key, vals, attr, dtype: dtype).tap do |this|
      if mtime = cols[3]?.try(&.to_i?)
        this.mtime = mtime
        this.uname = cols[4]? || "<init>"
        this.plock = cols[5]?.try(&.to_i?) || dlock
      else
        this.plock = dlock
      end
    end
  end

  def self.mtime(rtime = Time.utc)
    (rtime - EPOCH).total_minutes.round.to_i
  end

  getter key : String           # primary key
  property vals : Array(String) # primary values
  property attr : String = ""   # for extra attributes

  property mtime : Int32 = 0   # modification time
  property uname : String = "" # username
  property plock : Int32       # permission lock

  getter dtype : Int32
  getter worth : Float64 { calc_worth }

  def initialize(@key, @vals, @attr = "", @dtype = 2, @plock = 1)
  end

  def empty?
    @vals.empty? || @vals.first.empty?
  end

  def blank?
    empty? && @attr.empty?
  end

  def track?
    @mtime > 0
  end

  def rtime
    EPOCH + @mtime.minutes
  end

  def clear! : Void
    @vals.empty
    @attr = ""
    @mtime = 0
  end

  def merge!(other : self) : Bool
    return false if @plock > other.plock

    if @plock == other.plock
      return false if @mtime > other.mtime
    else
      @plock = other.plock
    end

    @vals = (other.vals + vals).uniq!
    @attr = other.attr

    @mtime = other.mtime
    @uname = other.uname

    @worth = nil # old worth is now worthless :)

    true
  end

  def println(io : IO, dlock = 1) : Nil
    return if @vals.empty?
    to_s(io, dlock)
    io << '\n'
  end

  def to_s(io : IO, dlock = 1)
    io << @key << '\t' << @vals.join(SEP_0)

    if @mtime > 0
      io << '\t' << @attr << '\t' << @mtime << '\t' << @uname
      io << '\t' << @plock if @plock != dlock
    elsif !attr.empty?
      io << '\t' << @attr
    end
  end

  private def calc_worth
    size = @key.size
    cost = @dtype / 5 + 2

    case attr[0]?
    when '🅷'
      cost += 0.25
    when '🅻'
      cost -= 0.25
    end

    size + size ** cost
  end
end

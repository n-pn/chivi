class Chivi::VpTerm
  SEP_0 = "ǀ"
  EPOCH = Time.utc(2020, 1, 1)

  def self.mtime(rtime = Time.utc)
    (rtime - EPOCH).total_minutes.round.to_i
  end

  def self.parse(line : String, dlock : Int32 = 1)
    cols = line.split('\t')

    key = cols[0]
    vals = (cols[1]? || "").split(SEP_0)
    attr = cols[2]? || ""

    new(key, vals, attr).tap do |this|
      if this.mtime = cols[3]?.try(&.to_i?)
        this.uname = cols[4]? || "<init>"
        this.plock = cols[5]?.try(&.to_i?) || dlock
      end
    end
  end

  getter key : String           # primary key
  property vals : Array(String) # primary values
  property attr : String = ""   # for extra attributes

  property mtime : Int32 = 0   # modification time
  property uname : String = "" # username
  property plock : Int32 = 1   # permission lock

  def initialize(@key, @vals, @attr = "")
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

    true
  end

  def clear! : Void
    @vals.empty
    @attr = ""
    @mtime = 0
  end

  def println(io : IO, dlock = 1) : Nil
    return if @vals.empty?

    io << key << '\t' << @vals.join(SEP_0)

    if @mtime > 0
      io << '\t' << @attr << '\t' << @mtime << '\t' << @uname
      io << '\t' << @plock if @plock != dlock
    elsif !attr.empty?
      io << '\t' << @attr
    end

    io << '\n'
  end
end

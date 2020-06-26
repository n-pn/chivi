struct LxItem
  EPOCH = Time.utc(2020, 1, 1)

  SEP_0 = "ǁ"
  SEP_1 = "¦"

  getter key : String
  getter vals : Array(String)
  getter mtime : Int32?
  getter extra : String?

  def self.from(line : String)
    cols = line.split(SEP_0, 4)

    key = cols[0]
    vals = split(cols[1]? || "")
    mtime = cols[2]?.try(&.to_i?)
    extra = cols[3]?

    new(key, vals, mtime, extra)
  end

  def self.split(vals : String)
    vals.empty? ? [""] : vals.split(SEP_1)
  end

  def self.mtime(time = Time.utc)
    (time - EPOCH).total_minutes.to_i
  end

  def initialize(@key : String, @vals : Array(String), @mtime = nil, @extra = nil)
  end

  def updated_at
    @mtime.try { |x| EPOCH + x.minutes }
  end

  def to_s(io : IO) : Void
    io << @key << SEP_0
    @vals.join(SEP_1, io)

    return unless mtime = @mtime
    io << SEP_0 << mtime

    return unless extra = @extra
    io << SEP_0 << @extra
  end

  def deleted?
    @vals.first.empty?
  end
end

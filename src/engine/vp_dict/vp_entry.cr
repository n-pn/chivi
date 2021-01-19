class CV::VpEntry
  DELIMIT = "ǀ"

  getter key : String
  getter vals : Array(String)
  getter attrs : String

  getter dtype : Int32
  getter worth : Float64 { calc_worth }

  def initialize(@key, @vals = [] of String, @attrs = "", @dtype = 2)
  end

  def merge!(other : self) : self
    @vals = (other.vals + @vals).uniq!
    @attrs = other.attr
    @worth = nil
    self
  end

  private def calc_worth
    cost = @dtype / 5 + 2

    case @attrs[0]?
    when '🅷'
      cost += 0.25
    when '🅻'
      cost -= 0.25
    end

    size = @key.size
    size + size ** cost
  end

  def empty?
    @vals.empty? || @vals.first.empty?
  end

  def to_s
    String.build { |io| to_s(io) }
  end

  def to_s(io : IO) : Nil
    {@key, @vals.join(DELIMIT), @attrs}.join(io, '\t')
  end

  def to_str
    String.build { |io| to_str(io) }
  end

  def to_str(io : IO) : Nil
    io << @key
    if @vals.empty?
      io << "\t\t" << @attrs unless @attrs.empty?
    else
      io << '\t' << @vals.join(DELIMIT)
      io << '\t' << @attrs unless @attrs.empty?
    end
  end

  #####################

  def self.from(cols : Array(String), dtype : Int32 = 0)
    key = cols[0]
    vals = cols.fetch(1, "").split(DELIMIT)
    attrs = cols.fetch(2, "")
    new(key, vals, attrs, dtype: dtype)
  end
end

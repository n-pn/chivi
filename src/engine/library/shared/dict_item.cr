class Engine::DictItem
  SEP_0 = "ǁ"
  SEP_1 = "¦"

  def self.parse(line : String, legacy : Bool = false)
    if legacy
      sep_0 = "="
      sep_1 = "/"
    else
      sep_0 = SEP_0
      sep_1 = SEP_1
    end

    cols = line.split(sep_0)
    vals = cols[1]?.try { |x| split(x, sep_1) }
    return cols[0], vals
  end

  def self.split(vals : String, sep : String | Regex = SEP_1) : Array(String)?
    vals.split(sep) unless vals.blank?
  end

  # instance

  getter key : String
  getter vals : Array(String)

  def initialize(@key, @vals = [] of String)
  end

  delegate :empty?, to: @vals

  def to_s
    String.build { |io| to_s(io) }
  end

  def to_s(io : IO)
    io << @key << SEP_0
    @vals.join(io, SEP_1)
  end
end

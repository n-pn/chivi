class Libcv::DictItem
  SEP_0 = "ǁ"
  SEP_1 = "¦"

  getter key : String
  property vals : Array(String)

  def initialize(@key, @vals = [] of String)
  end

  def to_s
    String.build { |io| to_s(io) }
  end

  def to_s(io : IO, trim = 4)
    vals = @vals.uniq
    vals = vals.last(trim) if trim > 0

    io << @key << SEP_0
    vals.join(io, SEP_1)
  end

  def puts(io : IO, trim = 4)
    to_s(io, trim)
    io << "\n"
  end

  # class methods

  alias Sep = String | Regex

  def self.parse(line : String, sep_0 : Sep = SEP_0, sep_1 : Seo = SEP_1)
    return cols[0], split(cols[1]?)
  end

  def self.parse_legacy(line : String)
    parse(line, "=", /[\/\|]/)
  end

  def self.split(vals : String?, sep : Sep = SEP_1)
    return vals.split(sep) unless vals.blank?
    [] of String
  end
end

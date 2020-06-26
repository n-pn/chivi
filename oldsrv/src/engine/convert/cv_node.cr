class CvNode
  SEP = "¦"

  property key : String
  property val : String
  property dic : Int32

  def initialize(@key : String, @val : String, @dic : Int32 = 0)
  end

  def initialize(key : Char, val : Char, @dic : Int32 = 0)
    @key = key.to_s
    @val = val.to_s
  end

  def initialize(chr : Char, @dic : Int32 = 0)
    @key = @val = chr.to_s
  end

  def to_s(io : IO)
    io << @key << SEP << @val << SEP << @dic
  end

  def to_s
    String.build { |io| to_s(io) }
  end
end

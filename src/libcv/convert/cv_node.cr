require "../../utils/text_util"

class CvNode
  SEP_0 = "ǁ"
  SEP_1 = "¦"

  property key : String
  property val : String
  property dic : Int32

  def initialize(@key : String, @val : String, @dic : Int32 = 0)
  end

  def initialize(key : Char, val : Char, @dic : Int32 = 0)
    @key = key.to_s
    @val = val.to_s
  end

  def initialize(char : Char, @dic : Int32 = 0)
    @key = @val = char.to_s
  end

  def to_s
    String.build { |io| to_s(io) }
  end

  def to_s(io : IO)
    io << @key << SEP_1 << @val << SEP_1 << @dic
  end

  def capitalize!
    @val = TextUtil.capitalize(@val)
  end

  def combine!(other : self)
    @key = other.key + @key
    @val = other.val + @val
  end
end

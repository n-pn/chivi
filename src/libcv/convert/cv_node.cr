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

  def to_s : String
    String.build { |io| to_s(io) }
  end

  def to_s(io : IO) : Nil
    {@key, @val, @dic}.join(io, SEP_1)
  end

  def capitalize!(mode = 1) : self
    @val = mode > 1 ? TextUtil.titleize(@val) : TextUtil.capitalize(@val)

    self
  end

  def combine!(other : self) : self
    @key = other.key + @key
    @val = other.val + @val

    self
  end
end

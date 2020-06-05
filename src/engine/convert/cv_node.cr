class CvNode
  SEP = "¦"

  property key : String
  property val : String
  property dic : Int32

  # def initialize(json : JSON::PullParser)
  #   json.read_begin_array
  #   @key = json.read_string
  #   @val = json.read_string
  #   @dic = json.read_int.to_i
  #   json.read_end_array
  # end

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

  # def to_json(json : JSON::Builder)
  #   json.array do
  #     json.string @key
  #     json.string @val
  #     json.number @dic
  #   end
  # end
end

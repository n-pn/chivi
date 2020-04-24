class Engine::CvNode
  property key : String
  property val : String
  property dic = 0

  def initialize(json : JSON::PullParser)
    json.read_begin_array
    @key = json.read_string
    @val = json.read_string
    @dic = json.read_int.to_i
    json.read_end_array
  end

  def initialize(@key : String, @val : String, @dic = 0)
  end

  def initialize(key : Char, val : Char, @dic = 0)
    @key = key.to_s
    @val = val.to_s
  end

  def initialize(chr : Char, @dic = 0)
    @key = @val = chr.to_s
  end

  def to_s(io : IO)
    io << "[" << @key << "|" << @val << "|" << @dic << "]"
  end

  def to_json(json : JSON::Builder)
    json.array do
      json.string @key
      json.string @val
      json.number @dic
    end
  end
end

class Engine::CvNodes < Array(Engine::CvNode)
  def keys
    map(&.key)
  end

  def vals
    map(&.vals)
  end

  def zh_text(io : IO)
    each { |item| io << item.key }
  end

  def zh_text
    String.build { |io| zh_text(io) }
  end

  def vi_text(io : IO)
    each { |item| io << item.val }
  end

  def vi_text
    String.build { |io| vi_text(io) }
  end

  def to_s(io)
    each { |item| item.to_json(io) }
  end
end

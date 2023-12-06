require "json"

struct MT::RawCon
  include JSON::Serializable

  getter cpos : String = ""
  getter body : String | Array(RawCon)

  def self.from_text(text : String, fixed : Bool = false)
    text = text.strip.gsub(/\n\s+/, ' ') unless fixed
    iter = Char::Reader.new(text)

    queue = [] of self

    while true
      cpos = String.build do |io|
        while char = iter.next_char
          break if char == ' '
          io << char
        end
      end

      char = iter.next_char
      if char == '('
        node = new(cpos, [] of self)
        if last = queue.last?
          last.body.as(Array) << node
        end

        queue << node
        next
      end

      body = String.build do |io|
        io << char
        while char = iter.next_char
          break if char == ')'
          io << char
        end
      end

      node = new(cpos, body)
      return node unless last = queue.last? # for special cases e.g `(OD 第１)`

      last.body.as(Array) << node

      while iter.next_char == ')' # either ' ' or ')'
        last = queue.pop
        return last if queue.empty?
      end

      iter.next_char # skip '('
    end

    queue.last
  end

  def self.from_json(json : String)
    pull = ::JSON::PullParser.new(json)
    queue = [] of self

    while true
      pull.read_begin_array
      cpos = pull.read_string
      pull.read_begin_array

      if pull.kind.begin_array?
        node = new(cpos, [] of self)
        if last = queue.last?
          last.body.as(Array) << node
        end

        queue << node
        next
      end

      body = pull.read_string
      pull.read_end_array
      pull.read_end_array

      node = new(cpos, body)
      # for special cases e.g `(OD 第１)`
      return node unless last = queue.last?
      last.body.as(Array) << node

      while pull.kind.end_array?
        pull.read_end_array
        pull.read_end_array
        last = queue.pop
        return last if queue.empty?
      end
    end

    queue.last
  end

  def initialize(@cpos, @body = "")
  end

  def to_json(builder : JSON::Builder)
    builder.array do
      builder.string @cpos

      if @body.is_a?(String)
        builder.array { builder.string @body }
      else
        @body.to_json(builder)
      end
    end
  end

  def to_s(io : IO) : Nil
    io << '(' << @cpos

    body = @body

    if body.is_a?(String)
      io << ' ' << body
    else
      body.each do |child|
        io << ' '
        child.to_s(io)
      end
    end

    io << ')'
  end

  SINGLE_LINES = {
    "VCD",
    "VRD",
    "VNV",
    "VPT",
    "VCP",
    "VAS",
    "DVP",
    "QP",
    "DNP",
    "DP",
    "CLP",
  }

  def inspect(io : IO, deep = 1) : Nil
    io << '(' << @cpos

    body = @body

    if body.is_a?(String)
      io << ' ' << body
    else
      on_line = body.size < 2 || @cpos.in?(SINGLE_LINES)

      body.each do |child|
        if on_line
          io << ' '
        else
          io << '\n'
          deep.times { io << "  " }
        end

        child.inspect(io, deep &+ 1)
      end
    end

    io << ')'
  end

  ###

  # test = from_text <<-TXT
  # (TOP (NP
  #   (QP (OD 第１) (CLP (M 章)))
  #   (NP (NN 密会))))
  # TXT

  # puts test
  # json = test.to_json

  # puts json
  # puts from_json(json)
end

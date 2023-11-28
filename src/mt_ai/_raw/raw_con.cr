require "json"

struct MT::RawCon
  include JSON::Serializable

  getter cpos : String = ""
  getter body : String | Array(RawCon)

  def initialize(@cpos, @body = "")
  end

  def self.new(input : String, fixed : Bool = false)
    input = input.strip.gsub(/\n\s+/, ' ') unless fixed

    iter = input.each_char
    raise "invalid input: expecting '(' at begin string" unless iter.next == '('

    new(iter)
  end

  def initialize(iter)
    @cpos = String.build do |sbuf|
      iter.each do |char|
        break if char == ' '
        sbuf << char
      end
    end

    @body = [] of RawCon

    while (char = iter.next.as?(Char))
      case char
      when '('
        @body.as(Array) << RawCon.new(iter)
      when ' '
        next
      when ')'
        break
      else
        @body = String.build do |sbuf|
          sbuf << char

          iter.each do |char|
            break if char == ')'
            sbuf << char
          end
        end

        break
      end
    end
  end

  def initialize(pull : ::JSON::PullParser)
    pull.read_begin_array
    @cpos = pull.read_string

    pull.read_begin_array

    if pull.kind.string?
      @body = pull.read_string
    else
      body = [] of RawCon

      while !pull.kind.end_array?
        body << RawCon.new(pull)
      end

      @body = body
    end

    pull.read_end_array
    pull.read_end_array
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

  # test = new <<-TXT
  # (TOP (NP
  #   (QP (OD 第１) (CLP (M 章)))
  #   (NP (NN 密会))))
  # TXT

  # puts test
end

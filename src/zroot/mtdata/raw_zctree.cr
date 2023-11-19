require "json"

struct ZR::RawConsti
  include JSON::Serializable

  getter cpos : String = ""
  getter body : String | Array(RawConsti)

  def initialize(@cpos, @body = "")
  end

  def initialize(pull : ::JSON::PullParser)
    pull.read_begin_array
    @cpos = pull.read_string

    pull.read_begin_array

    if pull.kind.string?
      @body = pull.read_string
    else
      body = [] of RawConsti

      while !pull.kind.end_array?
        body << RawConsti.new(pull)
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
end

require "./_shared"

struct MT::RawDep
  include JSON::Serializable

  getter idx : Int32
  getter dep : String

  def initialize(pull : ::JSON::PullParser)
    pull.read_begin_array

    @idx = pull.kind.string? ? pull.read_string.to_i : pull.read_int.to_i
    @dep = pull.read_string

    pull.read_end_array
  end

  def to_json(builder : JSON::Builder)
    builder.array do
      builder.number @idx
      builder.string @dep
    end
  end
end

require "json"

struct MT::RawEnt
  include JSON::Serializable

  getter zstr : String
  getter kind : String
  getter from : Int32
  getter upto : Int32

  def initialize(pull : ::JSON::PullParser)
    pull.read_begin_array

    @zstr = pull.read_string
    @kind = pull.read_string
    @from = pull.read_int.to_i
    @upto = pull.read_int.to_i

    pull.read_end_array
  end

  def to_json(builder : JSON::Builder)
    builder.array do
      builder.string @zstr
      builder.string @kind
      builder.scalar @from
      builder.scalar @upto
    end
  end
end

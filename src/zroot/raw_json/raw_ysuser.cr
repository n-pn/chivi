require "log"
require "./_raw_base"

class ZR::RawYsuser
  include JSON::Serializable

  @[JSON::Field(key: "userId")]
  getter user : EmbedYsuser

  @[JSON::Field(key: "praiseTotal")]
  getter like_count : Int32 = 0

  @[JSON::Field(key: "fansNumber")]
  getter star_count : Int32 = 0

  @[JSON::Field(key: "booklistNum")]
  getter list_total : Int32 = 0

  @[JSON::Field(key: "commentNum")]
  getter crit_total : Int32 = 0

  def self.from_json(string_or_io : String | IO) : self
    parser = JSON::PullParser.new(string_or_io)
    parser.on_key!("data") { new(parser) }
  end
end

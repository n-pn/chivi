require "json"

class Source
  include JSON::Serializable

  @[JSON::Field(key: "siteName")]
  property site : String

  @[JSON::Field(key: "bookPage")]
  property link : String
end

class YsInfo
  include JSON::Serializable

  property _id : Int32

  property title : String = ""
  property author : String = ""

  @[JSON::Field(key: "introduction")]
  property intro = ""

  @[JSON::Field(key: "classInfo")]
  property category : NamedTuple(classId: Int32, className: String)?

  property tags = [] of String
  property cover = ""

  property status = 0

  property shielded = false
  property hidden = 0

  @[JSON::Field(key: "countWord")]
  property word_count = 0_f64

  @[JSON::Field(key: "commentCount")]
  property crit_count = 0

  @[JSON::Field(key: "scorerCount")]
  property votes = 0
  property score = 0_f64

  @[JSON::Field(key: "updateAt")]
  property updated_at = Time.utc
end

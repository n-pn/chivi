require "log"
require "./_common"

class YS::RawYsUser
  include JSON::Serializable

  @[JSON::Field(key: "userId")]
  getter user : EmbedUser

  @[JSON::Field(key: "praiseTotal")]
  getter like_count : Int32 = 0

  @[JSON::Field(key: "fansNumber")]
  getter star_count : Int32 = 0

  @[JSON::Field(key: "booklistNum")]
  getter list_total : Int32 = 0

  @[JSON::Field(key: "commentNum")]
  getter crit_total : Int32 = 0

  def db_values(rtime : Int64 = Time.utc.to_unix)
    {
      @user._id,
      @user.name,
      @user.avatar,
      @like_count,
      @star_count,
      @list_total,
      @crit_total,
      rtime,
      rtime,
    }
  end

  ###################

  def self.from_raw_json(json : String) : self
    NamedTuple(data: self).from_json(json)[:data]
  end
end

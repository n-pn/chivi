require "log"
require "json"

class YS::RawYsUser
  struct User
    include JSON::Serializable

    getter _id : Int32

    @[JSON::Field(key: "userName")]
    getter name : String

    @[JSON::Field(key: "avatarId")]
    getter avatar : String
  end

  include JSON::Serializable

  @[JSON::Field(key: "userId")]
  getter user : User

  @[JSON::Field(key: "praiseTotal")]
  getter like_count : Int32 = 0

  @[JSON::Field(key: "fansNumber")]
  getter star_count : Int32 = 0

  @[JSON::Field(key: "booklistNum")]
  getter list_total : Int32 = 0

  @[JSON::Field(key: "commentNum")]
  getter crit_total : Int32 = 0

  def changeset(rtime : Int64 = Time.utc.to_unix)
    [
      @user._id,
      @user.name,
      @user.avatar,
      @like_count,
      @star_count,
      @list_total,
      @crit_total,
      rtime,
      rtime,
    ] of DB::Any
  end

  ###################

  def self.from_raw_json(json : String) : self
    NamedTuple(data: self).from_json(json)[:data]
  end
end

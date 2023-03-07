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

  DB_FIELDS = {
    "y_uid", "zname",
    "vname", "y_avatar",
    "like_count", "star_count",
    "list_total", "crit_total",
    "info_rtime",
  }

  def db_values(rtime : Int64 = Time.utc.to_unix)
    {
      @user.id, @user.name,
      @user.name, @user.avatar,
      @like_count, @star_count,
      @list_total, @crit_total,
      rtime,
    }
  end

  def self.from_json(string_or_io : String | IO)
    parser = JSON::PullParser.new(string_or_io)
    parser.on_key!("data") { new(parser) }
  end
end

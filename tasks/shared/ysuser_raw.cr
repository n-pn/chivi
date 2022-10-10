require "log"
require "json"
require "./bootstrap"
require "../../src/ysapp/models/*"

class CV::YsuserRaw
  struct User
    include JSON::Serializable

    getter _id : Int32
    @[JSON::Field(key: "userName")]
    getter name : String
  end

  include JSON::Serializable

  @[JSON::Field(key: "userId")]
  getter user : User

  getter _id : Int32 { user._id }
  getter name : String { user.name }

  @[JSON::Field(key: "praiseTotal")]
  getter like_count : Int32 = 0

  @[JSON::Field(key: "fansNumber")]
  getter star_count : Int32 = 0

  @[JSON::Field(key: "booklistNum")]
  getter list_total : Int32 = 0

  @[JSON::Field(key: "commentNum")]
  getter crit_total : Int32 = 0

  def seed!(stime : Int64 = Time.utc.to_unix)
    ysuser = YS::Ysuser.upsert!(self.name, self._id)

    ysuser.stime = stime

    ysuser.like_count = self.like_count if self.like_count > ysuser.like_count
    ysuser.star_count = self.star_count if self.star_count > ysuser.star_count

    ysuser.list_total = self.list_total if self.list_total > ysuser.list_total
    ysuser.crit_total = self.crit_total if self.crit_total > ysuser.crit_total

    ysuser.save!
  rescue err
    Log.error { err.inspect_with_backtrace.colorize.red }
  end

  ###################

  def self.from_info(json : String) : self
    NamedTuple(data: self).from_json(json)[:data]
  end
end

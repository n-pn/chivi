require "json"
require "./bootstrap"

class CV::YsreplRaw
  class User
    include JSON::Serializable

    getter _id : Int32
    @[JSON::Field(key: "userName")]
    getter name : String
  end

  include JSON::Serializable

  getter _id : String

  @[JSON::Field(key: "fromId")]
  getter user : User

  @[JSON::Field(key: "bookCommentId")]
  getter yscrit_id : String

  @[JSON::Field(key: "content")]
  getter ztext : String = ""

  @[JSON::Field(key: "praiseCount")]
  getter like_count : Int32 = 0

  @[JSON::Field(key: "replyCount")]
  getter repl_count : Int32 = 0

  @[JSON::Field(key: "createdAt")]
  getter created_at : Time

  def seed!(stime : Int64 = Time.utc.to_unix)
    ysrepl = Ysrepl.upsert!(self._id, self.created_at)

    ysrepl.yscrit = Yscrit.find!({origin_id: self.yscrit_id})
    ysrepl.ysuser = Ysuser.upsert!(self.user.name, self.user._id)

    ysrepl.stime = stime
    ysrepl.set_ztext(self.ztext)

    ysrepl.like_count = self.like_count if self.like_count > ysrepl.like_count
    ysrepl.repl_count = self.repl_count if self.repl_count > ysrepl.repl_count

    ysrepl.save!
  rescue err
    puts err.inspect_with_backtrace.colorize.red
  end

  ##################

  alias Data = NamedTuple(commentReply: Array(self), total: Int32)

  def self.from_list(json : String) : {Array(self), Int32}
    data = NamedTuple(data: Data).from_json(json)[:data]
    {data[:commentReply], data[:total]}
  end
end

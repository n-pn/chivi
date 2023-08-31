require "./_common"

class YS::RawYsrepl
  include JSON::Serializable

  @[JSON::Field(key: "_id")]
  getter yr_id : String

  @[JSON::Field(key: "fromId")]
  getter user : EmbedUser

  @[JSON::Field(key: "toId")]
  getter to_user : EmbedUser? = nil

  @[JSON::Field(key: "bookCommentId")]
  getter yc_id : String

  @[JSON::Field(key: "content")]
  getter ztext : String = ""

  @[JSON::Field(key: "praiseCount")]
  getter like_count : Int32 = 0

  @[JSON::Field(key: "replyCount")]
  getter repl_count : Int32 = 0

  @[JSON::Field(key: "createdAt")]
  getter created_at : Time

  ##################

  alias Data = NamedTuple(commentReply: Array(self), total: Int32)

  def self.from_list_json(json : String) : {Array(self), Int32}
    data = NamedTuple(data: Data).from_json(json)[:data]
    {data[:commentReply], data[:total]}
  end
end

struct YS::RawCritReplies
  include JSON::Serializable

  @[JSON::Field(key: "commentReply")]
  getter repls : Array(YS::RawYsrepl)

  getter total : Int32

  def self.from_json(string_or_io : String | IO)
    parser = JSON::PullParser.new(string_or_io)
    parser.on_key!("data") { new(parser) }
  end
end

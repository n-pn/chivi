require "./_common"

class YS::RawYscrit
  include JSON::Serializable

  @[JSON::Field(key: "_id")]
  getter yc_id : String

  @[JSON::Field(key: "bookId")]
  getter book : EmbedBook

  @[JSON::Field(key: "createrId")]
  getter user : EmbedUser

  @[JSON::Field(key: "score")]
  getter stars : Int32 = 3

  @[JSON::Field(key: "content")]
  getter ztext : String = ""

  getter tags : Array(String) = [] of String

  @[JSON::Field(key: "praiseCount")]
  getter like_count : Int32 = 0

  @[JSON::Field(key: "replyCount")]
  getter repl_total : Int32 = 0

  @[JSON::Field(key: "createdAt")]
  getter created_at : Time

  @[JSON::Field(key: "updateAt")]
  getter updated_at : Time?
end

record YS::RawBookComments, comments : Array(YS::RawYscrit), total : Int32 do
  include JSON::Serializable

  def self.from_json(string_or_io : String | IO)
    parser = JSON::PullParser.new(string_or_io)
    parser.on_key!("data") { new(parser) }
  end
end

record YS::RawListEntries, books : Array(YS::RawYscrit), total : Int32 do
  include JSON::Serializable

  def self.from_json(string_or_io : String | IO)
    parser = JSON::PullParser.new(string_or_io)
    parser.on_key!("data") { new(parser) }
  end
end

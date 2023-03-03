require "./_common"

class YS::RawYsCrit
  include JSON::Serializable

  @[JSON::Field(key: "_id")]
  getter y_cid : String

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

  # def db_changes
  #   fields = [] of String
  #   values = [] of DB::Any | Array(String)

  #   fields << "origin_id"
  #   values << self.uuid

  #   fields << "ysbook_id"
  #   values << self.uuid

  #   {fields, values}
  # end
end

record YS::RawBookComments, comments : Array(YS::RawYsCrit), total : Int32 do
  include JSON::Serializable

  def self.from_json(json : String)
    raise "invalid json" unless json.starts_with?('{')

    parser = JSON::PullParser.new(json)
    parser.on_key!("data") { new(parser) }
  end
end

record YS::RawListEntries, books : Array(YS::RawYsCrit), total : Int32 do
  include JSON::Serializable

  def self.from_json(json : String)
    raise "invalid json" unless json.starts_with?('{')

    parser = JSON::PullParser.new(json)
    parser.on_key!("data") { new(parser) }
  end
end

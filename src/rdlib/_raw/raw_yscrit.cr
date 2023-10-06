require "./_yousuu"

class RawYscrit
  include JSON::Serializable

  @[JSON::Field(key: "_id")]
  getter yc_id : String

  @[JSON::Field(key: "bookId")]
  getter book : EmbedYsbook

  @[JSON::Field(key: "createrId")]
  getter user : EmbedYsuser

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

  def ztext?
    return if @ztext.blank? || @ztext == "请登录查看评论内容"
    @ztext.tr("\u0000", "\n").lines.map(&.strip).reject(&.empty?).join('\n')
  end
end

struct ZR::RawYsbookComments
  include JSON::Serializable

  getter comments : Array(RawYscrit)
  getter total : Int32

  def self.from_json(string_or_io : String | IO)
    parser = JSON::PullParser.new(string_or_io)
    parser.on_key!("data") { new(parser) }
  end
end

struct ZR::RawYslistEntries
  include JSON::Serializable

  getter books : Array(RawYscrit)
  getter total : Int32

  def self.from_json(string_or_io : String | IO)
    parser = JSON::PullParser.new(string_or_io)
    parser.on_key!("data") { new(parser) }
  end
end

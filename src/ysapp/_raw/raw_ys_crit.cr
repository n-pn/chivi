require "./_common"

class YS::RawYsCrit
  include JSON::Serializable

  @[JSON::Field(key: "_id")]
  getter uuid : String

  @[JSON::Field(key: "bookId")]
  getter book : EmbedBook

  @[JSON::Field(key: "createrId")]
  getter user : EmbedBook

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

  record BookComments, comments : Array(RawYsCrit), total : Int32 do
    include JSON::Serializable
  end

  record BooklistEntries, books : Array(RawYsCrit), total : Int32 do
    include JSON::Serializable
  end

  def self.from_book_json(json : String) : {Array(self), Int32}
    data = NamedTuple(data: BookComments).from_json(json)[:data]
    {data.comments, data.total}
  end

  def self.from_list_json(json : String) : {Array(self), Int32}
    data = NamedTuple(data: BooklistEntries).from_json(json)[:data]
    {data.books, data.total}
  end
end

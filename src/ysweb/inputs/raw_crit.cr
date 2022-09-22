require "json"

class YS::RawCrit
  class Book
    include JSON::Serializable

    getter _id : Int64 = 0_i64

    @[JSON::Field(key: "bookId")]
    getter book_id : Int64 = 0_i64

    getter id : Int64 { _id > 0 ? _id : book_id }

    getter title : String
    getter author : String
  end

  struct User
    include JSON::Serializable

    getter _id : Int32

    @[JSON::Field(key: "userName")]
    getter name : String
  end

  include JSON::Serializable

  getter _id : String

  @[JSON::Field(key: "score")]
  getter stars : Int32 = 3

  @[JSON::Field(key: "content")]
  getter ztext : String = ""

  getter tags : Array(String) = [] of String

  @[JSON::Field(key: "praiseCount")]
  getter like_count : Int32 = 0

  @[JSON::Field(key: "replyCount")]
  getter repl_total : Int32 = 0

  # getter createdAt : Time # ignoring

  @[JSON::Field(key: "createdAt")]
  getter created_at : Time

  @[JSON::Field(key: "updateAt")]
  getter updated_at : Time?

  @[JSON::Field(key: "bookId")]
  getter book : Book

  @[JSON::Field(key: "createrId")]
  getter user : User

  alias BookComment = NamedTuple(comments: Array(self), total: Int32)
  alias ListComment = NamedTuple(books: Array(self), total: Int32)

  def self.from_book_json(json : String) : {Array(self), Int32}
    data = NamedTuple(data: BookComment).from_json(json)[:data]
    {data[:comments], data[:total]}
  end

  def self.from_list_json(json : String) : {Array(self), Int32}
    data = NamedTuple(data: ListComment).from_json(json)[:data]
    {data[:books], data[:total]}
  end
end

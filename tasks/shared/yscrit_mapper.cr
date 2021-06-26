require "json"

class CV::YscritMapper
  class Book
    include JSON::Serializable
    getter _id : String
    getter title : String
    getter author : String
  end

  class User
    include JSON::Serializable

    getter _id : String

    @[JSON::Field(key: "userName")]
    getter name : String
  end

  include JSON::Serializable

  getter _id : String
  getter id : Int64 { _id[8..].to_i64(base: 16) }

  @[JSON::Field(key: "score")]
  getter stars : Int32 = 3

  @[JSON::Field(key: "content")]
  getter ztext : String = ""

  @[JSON::Field(key: "praiseCount")]
  getter like_count : Int32 = 0

  @[JSON::Field(key: "replyCount")]
  getter repl_count : Int32 = 0

  # getter createdAt : Time # ignoring
  getter created_at : Time { Time.unix(_id[0..7].to_i64(base: 16)) }

  @[JSON::Field(key: "updateAt")]
  getter updated_at : Time

  @[JSON::Field(key: "bookId")]
  getter book : Book
end

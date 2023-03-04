require "json"

struct YS::EmbedUser
  include JSON::Serializable

  getter _id : Int32

  @[JSON::Field(key: "userName")]
  getter name : String

  @[JSON::Field(key: "avatarId")]
  getter avatar : String
end

struct YS::EmbedBook
  include JSON::Serializable

  @[JSON::Field(key: "_id")]
  getter id : Int32 { book_id }

  @[JSON::Field(key: "bookId")]
  getter book_id : Int32 = 0

  @[JSON::Field(key: "title")]
  getter btitle : String

  getter author : String
end

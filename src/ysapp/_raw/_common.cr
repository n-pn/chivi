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

  getter _id : Int32 = 0_i64

  @[JSON::Field(key: "bookId")]
  getter book_id : Int32 = 0_i64

  getter id : Int32 { _id > 0 ? _id : book_id }

  getter title : String
  getter author : String
end

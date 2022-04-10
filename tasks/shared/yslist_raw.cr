require "json"

class CV::YslistRaw
  class User
    include JSON::Serializable

    getter _id : Int64

    @[JSON::Field(key: "userName")]
    getter name : String
  end

  include JSON::Serialize

  getter _id : String
  getter id : Int64 { _id[12..].to_i64(base: 16) }

  @[JSON::Field(key: "createrId")]
  getter user : String

  @[JSON::Field(key: "clicks")]
  getter view_count : Int32 = 0

  @[JSON::Field(key: "praiseTotal")]
  getter like_count : Int32 = 0

  @[JSON::Field(key: "bookTotal")]
  getter book_total : Int32 = 0

  @[JSON::Field(key: "createdAt")]
  getter created_at : Time
  @[JSON::Field(key: "updateAt")]
  getter updated_at : Time

  @[JSON::Field(key: "praiseAt")]
  getter praised_at : Time

  @[JSON::Field(key: "title")]
  getter zname : String

  @[JSON::Field(key: "listType")]
  getter klass : String = "male"

  @[JSON::Field(key: "booklistId")]
  getter list_id : String
end

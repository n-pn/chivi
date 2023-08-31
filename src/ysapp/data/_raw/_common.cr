require "log"
require "json"
require "zstd"

require "../../_util/text_util"

def read_zstd(path : String)
  file = File.open(path, "r")
  Zstd::Decompress::IO.open(file, sync_close: true, &.gets_to_end)
end

struct YS::EmbedUser
  include JSON::Serializable

  @[JSON::Field(key: "_id")]
  getter id : Int32

  @[JSON::Field(key: "userName")]
  getter name : String = ""

  @[JSON::Field(key: "avatarId")]
  getter avatar : String = ""
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

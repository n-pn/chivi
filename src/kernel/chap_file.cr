require "json"

class ChapFile
  include JSON::Serializable

  property idx : Int32
  property uid : String

  property url_slug : String

  property zh_title : String
  property vi_title : String

  property zh_volume : String
  property vi_volume : String

  property created_at : Int64
  property updated_at : Int64

  property origin_uid : String?
end

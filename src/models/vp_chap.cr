require "json"

class VpChap
  include JSON::Serializable

  property site : String
  property bsid : String
  property csid : String

  property idx : Int32

  property zh_title : String = ""
  property vi_title : String = ""

  property url_slug : String = ""

  property zh_volume : String = ""
  property vi_volume : String = ""

  property created_at : Int64?
  property updated_at : Int64?
end

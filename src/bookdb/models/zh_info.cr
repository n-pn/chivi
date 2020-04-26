require "json"

class ZhInfo
  include JSON::Serializable

  property site = ""
  property bsid = ""

  property title = ""
  property author = ""

  property intro = ""
  property genre = ""

  property tags = [] of String
  property cover = ""

  property state = 0_i32
  property mtime = 0_i64

  def initialize(@site : String, @bsid : String)
  end
end

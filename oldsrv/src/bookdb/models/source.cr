require "json"
require "file_utils"

class Source
  ROOT = File.join("data", "books", "sources")

  def self.setup!
    FileUtils.mkdir_p(ROOT)
  end

  class Data
    include JSON::Serializable

    property type : Int32 = 0 # types: 0 => auto, 1 => locked, 2 => manual
    property host : String = ""
    property bsid : String = ""

    property mftime : Int64 = 0_i64
    property prefered : Bool = false
    property chap_count : Int32 = 0

    property latest_csid : String = ""
    property latest_text : String = ""
    property latest_slug : String = ""
  end

  def initialize(@uuid : String)
  end
end

require "json"
require "colorize"
require "file_utils"
require "./chap_item"

class BookSeed
  ROOT = File.join("var", "appcv", "book_seeds")

  def self.setup!(uuid : String)
    FileUtils.mkdir_p(File.join(ROOT, uuid))
  end

  class Data
    include JSON::Serializable

    property type : Int32 = 0 # types: 0 => auto, 1 => locked, 2 => manual
    property name : String = ""
    property sbid : String = ""

    property mftime : Int64 = 0_i64
    property prefered : Bool = false
    property chap_count : Int32 = 0
    property latest_chap : ChapItem
  end

  def initialize(@uuid : String)
  end
end

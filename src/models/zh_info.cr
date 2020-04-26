require "json"

# require "../utils/data_path"
# require "../utils/parse_time"

class ZhInfo
  include JSON::Serializable

  property title = ""
  property author = ""

  property intro = ""
  property genre = ""

  property tags = [] of String
  property cover = ""

  property state = 0_i32
  property mtime = 0_i64

  def initialize
  end

  # def save!
  #   File.write(Utils.zh_info_path(@site, @bsid), to_json)
  # end

  # def self.load!(site : String, bsid : String)
  #   from_json(File.read(Utils.zh_info_path(site, bsid)))
  # end
end

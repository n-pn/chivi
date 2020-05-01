require "json"

require "../../utils/hash_id"

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

  def label
    "#{title}--#{author}"
  end

  def hash
    Utils.hash_id(label)
  end

  def intro=(intro : String)
    @intro = intro.tr("　 ", " ")
      .split(/\s{2,}|\n+/)
      .map(&.strip)
      .reject(&.empty?)
      .join("\n")
  end
end

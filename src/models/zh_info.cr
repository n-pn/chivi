require "json"
require "../utils/hash_id"

class ZhInfo
  include JSON::Serializable

  property site = ""
  property bsid = ""

  property uuid = ""

  property title = ""
  property author = ""
  property intro = ""
  property cover = ""
  property genre = ""
  property tags = [] of String

  property status = 0_i32
  property update = 0_i64

  def initialize(@site, @bsid)
  end

  def uuid
    return @uuid unless @uuid.empty?
    reset_uuid
  end

  def reset_uuid
    @uuid = Utils.hash_id("#{@title}--#{@author}")
  end
end

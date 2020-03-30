require "json"

require "../engine"

class VpChap
  include JSON::Serializable

  property csid : String

  property url_slug : String = ""

  property zh_title : String = ""
  property vi_title : String = ""

  property zh_volume : String = ""
  property vi_volume : String = ""

  def initialize(@csid, @zh_title, @zh_volume)
    translate!
  end

  def translate!
    @vi_title = Engine.translate(@zh_title, title: true)
    @vi_volume = Engine.translate(@zh_volume, title: true)
    @url_slug = CUtil.slugify(@vi_title)
  end
end

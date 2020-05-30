require "json"

class VpChap
  include JSON::Serializable

  property csid = ""

  property zh_title = ""
  property vi_title = ""

  property zh_volume = ""
  property vi_volume = ""

  property title_slug = ""

  def initialize
  end
end

require "json"

require "../utils/fix_info"

class ZhChap
  include JSON::Serializable

  property csid : String = "0"
  property title : String = ""
  property volume : String = "正文"

  def initialize(@csid, title, volume = "")
    if volume.empty?
      @title, @volume = Utils.split_title(title)
    else
      @title = Utils.fix_title(title)
      @volume = Utils.clean_title(volume)
    end
  end

  def to_s(io : IO)
    io << to_pretty_json
  end
end

# puts ZhChap.new("3", "第一集 汉宫日暮 第一章　　长门灯暗")

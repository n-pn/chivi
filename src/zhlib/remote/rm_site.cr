require "yaml"

class ZH::RmSite
  include YAML::Serializable

  getter encoding = "GBK"

  getter text : Text

  def text_link(bid : Int32, cid : Int32)
    text.href % {div: bid // 1000, bid: bid, cid: cid}
  end

  class Text
    include YAML::Serializable

    getter href : String = ""

    getter title_css = "h1@text"
    getter title_del = [] of String

    getter paras_css = "#content"

    getter tkind : Int32 = 0
    getter pkind : Int32 = 0
    getter cookie : String = ""
  end

  ALL = Hash(String, self).from_yaml {{ read_file("#{__DIR__}/rm_site.yml") }}

  def self.[](sname : String)
    ALL[sname]? || ALL["_base"]
  end
end

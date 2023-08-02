# require "yaml"

# class ZH::RmSite
#   include YAML::Serializable

#   getter encoding = "GBK"

#   getter chap : Chap

#   def chap_link(bid : Int32, cid : Int32)
#     chap.href % {div: bid // 1000, bid: bid, cid: cid}
#   end

#   class Chap
#     include YAML::Serializable

#     getter href : String = ""

#     getter bname = ".con_top > a:last-child@text"
#     getter title = "h1@text"
#     getter paras = "#content"

#     getter cookie : String = ""
#     getter? reorder : Bool = false
#   end

#   ALL = Hash(String, self).from_yaml {{ read_file("#{__DIR__}/rm_site.yml") }}

#   def self.[](sname : String)
#     ALL[sname]? || ALL["_base"]
#   end
# end

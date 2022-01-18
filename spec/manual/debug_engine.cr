require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("esmah6wp")

inp = "顶尖高手叶秋"
res = GENERIC.cv_plain(inp)

{res.inspect, inp, res}.each do |text|
  puts "--------", text
end

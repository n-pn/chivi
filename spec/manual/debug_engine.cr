require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("combine")

inp = "这几栋居民楼里"
res = GENERIC.cv_title_full(inp)

{res.inspect, inp, res}.each do |text|
  puts "--------", text
end

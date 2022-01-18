require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("fnjqty5r")

inp = "小白狗飞快地跑出去"
res = GENERIC.cv_plain(inp)

{res.inspect, inp, res}.each do |text|
  puts "--------", text
end

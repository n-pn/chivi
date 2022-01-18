require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("m1596jjw")

inp = "妖怪给人的感觉，就是"
res = GENERIC.cv_plain(inp)

{res.inspect, inp, res}.each do |text|
  puts "--------", text
end

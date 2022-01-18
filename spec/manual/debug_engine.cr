require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("m1596jjw")

inp = "突然我对自己的死亡不是很在乎"
res = GENERIC.cv_plain(inp)

{res.inspect, inp, res}.each do |text|
  puts "--------", text
end

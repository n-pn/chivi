require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("m1596jjw")

inp = "我的弟子和你的女儿"
res = GENERIC.cv_plain(inp)

{res.inspect, inp, res}.each do |text|
  puts "--------", text
end

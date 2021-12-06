require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("fnjqty5r")

inp = "很好的一本“仙书”了！"
res = GENERIC.cv_plain(inp)

[res.inspect, inp, res].each do |text|
  puts "--------", text
end

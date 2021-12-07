require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("fnjqty5r")

inp = "隐含愤怒的杀机"
res = GENERIC.cv_plain(inp)

[res.inspect, inp, res].each do |text|
  puts "--------", text
end

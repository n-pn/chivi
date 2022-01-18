require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("w5d6vmqr")

inp = "嘤嘤嘤嘤嘤嘤嘤嘤嘤嘤嘤嘤嘤嘤嘤嘤嘤嘤嘤嘤嘤嘤嘤嘤嘤嘤嘤嘤嘤嘤嘤嘤嘤!"
res = GENERIC.cv_plain(inp)

{res.inspect, inp, res}.each do |text|
  puts "--------", text
end

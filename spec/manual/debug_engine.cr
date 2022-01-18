require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("6y9qp333")

inp = "再告诉你一个好消息"
res = GENERIC.cv_plain(inp)

{res.inspect, inp, res}.each do |text|
  puts "--------", text
end

require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("w5d6vmqr")

inp = "她的魂海之中"
res = GENERIC.cv_plain(inp)

{res.inspect, inp, res}.each do |text|
  puts "--------", text
end

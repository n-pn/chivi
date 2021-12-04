require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("21kd5dn7")

inp = "五大贵族之一"
res = GENERIC.cv_plain(inp)

puts res.inspect, inp, res

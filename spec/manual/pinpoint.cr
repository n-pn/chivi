require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("21kd5dn7")

inp = "这一次，她对于自己的演艺事业，突然有了空前的热情。"
res = GENERIC.cv_plain(inp)

puts res.inspect, inp, res

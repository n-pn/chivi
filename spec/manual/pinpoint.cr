require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("combine")

inp = "http://t.cn/ROjEGXy"
res = GENERIC.cv_plain(inp)

puts inp, res.inspect, res

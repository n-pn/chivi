require "../../src/libcv/mt_core"

GENERIC = CV::MtCore.generic_mtl("combine")

inp = "气运塔层数都不高，光芒也只是偶尔闪烁几层。"
res = GENERIC.cv_plain(inp)

puts inp, res.inspect, res

require "../../src/libcv/mt_core"

GENERIC = CV::MtCore.generic_mtl("combine")

inp = "挪了挪"

res = GENERIC.cv_plain(inp)
puts inp, res.inspect, res.to_s

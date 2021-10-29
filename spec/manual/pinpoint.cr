require "../../src/libcv/mt_core"

GENERIC = CV::MtCore.generic_mtl("combine")

inp = "郑重其事地走向金帐。"
res = GENERIC.cv_plain(inp)

puts inp, res.inspect, res

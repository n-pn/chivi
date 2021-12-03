require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("various")

inp = "金币，或者说是一周前那场交易的尾款，足足有20000枚。"
res = GENERIC.cv_plain(inp)

puts inp, res.inspect, res

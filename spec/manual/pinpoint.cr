require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("7wr5czfg")

inp = "自由恋爱的价值对于一些人来说就像世界上最昂贵的奢侈品，是那样的遥不可及。"
res = GENERIC.cv_plain(inp)

puts inp, res.inspect, res

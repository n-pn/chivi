require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("7wr5czfg")

inp = "在前世记忆中的名字。"
res = GENERIC.cv_plain(inp)

puts inp, res.inspect, res

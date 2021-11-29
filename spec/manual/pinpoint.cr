require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("7wr5czfg")

inp = "那这些隐藏在我们中的人该怎么辨认呢"
res = GENERIC.cv_plain(inp)

puts inp, res.inspect, res

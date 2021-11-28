require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("7wr5czfg")

inp = "非《惊悚乐园》"
res = GENERIC.cv_plain(inp)

puts inp, res.inspect, res

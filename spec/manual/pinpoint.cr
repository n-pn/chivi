require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("7zx48vye")

inp = "不世出之天才"
res = GENERIC.cv_plain(inp)

puts inp, res.inspect, res

require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("7zx48vye")

inp = "罗亚的房间内"
res = GENERIC.cv_plain(inp)

puts inp, res.inspect, res

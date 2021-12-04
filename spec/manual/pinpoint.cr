require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("7zx48vye")

inp = "就像一只银色的猫咪"
res = GENERIC.cv_plain(inp)

puts res.inspect, inp, res

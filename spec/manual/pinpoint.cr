require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("czfrmpxx")

inp = "第二重"
res = GENERIC.cv_plain(inp)

puts inp, res.inspect, res

require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("czfrmpxx")

inp = "史上第一掌门"
res = GENERIC.cv_plain(inp)

puts inp, res.inspect, res

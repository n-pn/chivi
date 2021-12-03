require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("various")

inp = "那就好"
res = GENERIC.cv_plain(inp)

puts inp, res.inspect, res

require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("various")

inp = "“这，这是为什么啊？”"
res = GENERIC.cv_plain(inp)

puts inp, res.inspect, res

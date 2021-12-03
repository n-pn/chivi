require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("various")

inp = "还有这样那样的毛病"
res = GENERIC.cv_plain(inp)

puts inp, res.inspect, res

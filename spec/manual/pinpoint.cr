require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("7zx48vye")

inp = "大的那个是男款"
res = GENERIC.cv_plain(inp)

puts inp, res.inspect, res

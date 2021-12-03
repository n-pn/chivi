require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("various")

inp = "阿尔文庆幸着自己昨天的果断"
res = GENERIC.cv_plain(inp)

puts inp, res.inspect, res

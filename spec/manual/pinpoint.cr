require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("czfrmpxx")

inp = "2015年2月5日9时21分"
res = GENERIC.cv_plain(inp)

puts inp, res.inspect, res

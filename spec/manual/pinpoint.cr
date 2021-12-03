require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("7zx48vye")

inp = "利用系统将桑卓玛的安魂灯换了出来"
res = GENERIC.cv_plain(inp)

puts inp, res.inspect, res

require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("7zx48vye")

inp = "在被告缺席的情况下，其余几个忿忿不平的队员已经对杰瑞的罪行进行了判决，可怜的杰瑞对此还一无所知呢。"
res = GENERIC.cv_plain(inp)

puts inp, res.inspect, res

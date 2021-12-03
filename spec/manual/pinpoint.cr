require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("various")

inp = "并表示会尽快想办法将尾款秘密送过去"
res = GENERIC.cv_plain(inp)

puts inp, res.inspect, res

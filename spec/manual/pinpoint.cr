require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("7zx48vye")

inp = "本来原计划半个月才能完成的衣服"
res = GENERIC.cv_plain(inp)

puts inp, res.inspect, res

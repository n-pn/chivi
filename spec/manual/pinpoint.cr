require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("7zx48vye")

inp = "出实体书了吗？实体书有新情节吗？？？哎，如果实体书没有新情节，明显是TJ 来的。。。"
res = GENERIC.cv_plain(inp)

puts inp, res.inspect, res

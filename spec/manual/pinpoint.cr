require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("7zx48vye")

inp = "小脸亲昵的蹭着少年的胸口"
res = GENERIC.cv_plain(inp)

puts inp, res.inspect, res

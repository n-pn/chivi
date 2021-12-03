require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("various")

inp = "还广受众多昆仑外门弟子爱戴，可以说未来已经是一片坦途。"
res = GENERIC.cv_plain(inp)

puts inp, res.inspect, res

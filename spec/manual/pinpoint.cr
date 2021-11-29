require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("various")

inp = "“那我们教国的贵族如果是异教徒的话会怎么样？也不会杀吗？”"
res = GENERIC.cv_plain(inp)

puts inp, res.inspect, res

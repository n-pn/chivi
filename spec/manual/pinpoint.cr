require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("7zx48vye")

inp = "一个不漂亮但很温柔的妻子"
res = GENERIC.cv_plain(inp)

puts res.inspect, inp, res

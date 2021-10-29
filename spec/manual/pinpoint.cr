require "../../src/libcv/mt_core"

GENERIC = CV::MtCore.generic_mtl("combine")

inp = "“娘娘说那里有我的机缘。”"
res = GENERIC.cv_plain(inp)

puts inp, res.inspect, res

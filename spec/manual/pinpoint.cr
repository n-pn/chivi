require "../../src/libcv/mt_core"

GENERIC = CV::MtCore.generic_mtl("combine")

inp = "至于一百五十以上者比比皆是"
res = GENERIC.cv_plain(inp)

puts inp, res.inspect, res

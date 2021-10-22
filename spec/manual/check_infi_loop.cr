require "../../src/libcv/mt_core"

GENERIC = CV::MtCore.generic_mtl("combine")

test = "早上6点"

res = GENERIC.cv_plain(test)
puts res.inspect, res.to_s

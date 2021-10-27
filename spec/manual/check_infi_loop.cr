require "../../src/libcv/mt_core"

GENERIC = CV::MtCore.generic_mtl("combine")

test = "二百余"

res = GENERIC.cv_plain(test)
puts res.inspect, res.to_s

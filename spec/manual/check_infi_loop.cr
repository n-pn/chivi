require "../../src/libcv/mt_core"

GENERIC = CV::MtCore.generic_mtl("combine")

test = "白捡7万，开心。"

res = GENERIC.cv_plain(test)
puts res.inspect, res.to_s

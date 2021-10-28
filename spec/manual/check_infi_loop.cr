require "../../src/libcv/mt_core"

GENERIC = CV::MtCore.generic_mtl("combine")

test = "黑人太多的巴黎被他排除掉"

res = GENERIC.cv_plain(test)
puts res.inspect, res.to_s

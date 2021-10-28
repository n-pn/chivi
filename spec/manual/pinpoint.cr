require "../../src/libcv/mt_core"

GENERIC = CV::MtCore.generic_mtl("combine")

test = "说到浪漫，多崎司第一时间想起的是巴黎和米兰这两座城市。一番考虑之后，黑人太多的巴黎被他排除掉，所以选择先学意大利语。"

res = GENERIC.cv_plain(test)
puts res.inspect, res.to_s

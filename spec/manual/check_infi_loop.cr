require "../../src/libcv/mt_core"

GENERIC = CV::MtCore.generic_mtl("combine")

test = "《连城诀》范畴，甚非“性情”二。"

res = GENERIC.cv_plain(test)
puts res.inspect, res.to_s

require "../../src/libcv/mt_core"

GENERIC = CV::MtCore.generic_mtl("combine")

test = "你们英语老师和他的婚外情对象啊！"

res = GENERIC.cv_plain(test)
puts res.inspect, res.to_s

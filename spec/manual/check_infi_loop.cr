require "../../src/libcv/mt_core"

GENERIC = CV::MtCore.generic_mtl("combine")

test = "穿过高高的玉米田，晃过如悬挂黑宝石的葡萄架，斜坡上种有蜜橘。"

res = GENERIC.cv_plain(test)
puts res.inspect, res.to_s

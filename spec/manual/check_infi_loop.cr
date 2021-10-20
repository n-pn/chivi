require "../../src/libcv/mt_core"

GENERIC = CV::MtCore.generic_mtl("combine")

test = "老谢尔盖顿时寒毛竖起：“大炮？”"

res = GENERIC.cv_plain(test)
puts res.inspect, res.to_s

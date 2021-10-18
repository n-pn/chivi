require "../../src/libcv/mt_core"

GENERIC = CV::MtCore.generic_mtl("combine")

test = "朝圣者头顶这样的偈子，就是在表明自己的决心——不畏生死，超脱生死。"

res = GENERIC.cv_plain(test)
puts res.inspect, res.to_s

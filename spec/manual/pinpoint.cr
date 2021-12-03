require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("7zx48vye")

inp = "今天的少女上的是礼仪课，稍微有些耗费体力，此时正在休息中，罗亚的到来让爱丽莎的脸上立即浮现出笑容。"
res = GENERIC.cv_plain(inp)

puts inp, res.inspect, res

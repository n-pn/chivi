require "../../src/libcv/mt_core"

GENERIC = CV::MtCore.generic_mtl("combine")

inp = "“看过小师叔你和彭乐云之战，朱师兄和雷师弟他们都对你心服口服了，最近碰面，大家讨论的焦点就是四月份的大学武道会全国赛，在说上清的彭乐云、崆峒的任莉、星海的安朝阳和甄焕生，以及吴越会冰神宗的小师叔你，究竟谁能独领风骚。”"
res = GENERIC.cv_plain(inp)

puts inp, res.inspect, res

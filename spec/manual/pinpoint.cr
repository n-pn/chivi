require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("7zx48vye")

inp = "而是他给卡帝亚买的。"
res = GENERIC.cv_plain(inp)

puts inp, res.inspect, res

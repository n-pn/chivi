require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("7zx48vye")

inp = "买衣服的时候罗亚回顾记忆，发现十年父子下来，罗亚还一件东西没给卡帝亚买过呢，想到这些有些惭愧又恰好赚了一笔的罗亚便自己掏钱订了一件
大衣，也算是表达一下对自己这个便宜老爹的感谢。"
res = GENERIC.cv_plain(inp)

puts inp, res.inspect, res

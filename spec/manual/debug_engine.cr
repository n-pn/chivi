require "../../src/cvmtl/mt_core"

inp = ARGV[0]? || "但这世界似乎跟自己想的不太一样？女巫真实存在，而且还真具有魔力？
女巫种田文，将种田进行到底。"
dic = ARGV[1]? || "mvrwv4p4"

mtl = CV::MtCore.generic_mtl(dic)
res = mtl.cv_plain(inp)
{res.inspect, inp, res}.each { |text| puts "--------", text }

require "../../src/cvmtl/mt_core"

inp = ARGV[0]? || "来购买德意志提供的一切…"
dic = ARGV[1]? || "mvrwv4p4"

mtl = CV::MtCore.generic_mtl(dic)
res = mtl.cv_plain(inp)
{res.inspect, inp, res}.each { |text| puts "--------", text }

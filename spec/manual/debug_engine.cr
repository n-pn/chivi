require "../../src/cvmtl/mt_core"

inp = ARGV[0]? || "不设防盗对她们这些一直追正版的读者太不公平"
dic = ARGV[1]? || "mvrwv4p4"

mtl = CV::MtCore.generic_mtl(dic)
res = mtl.cv_plain(inp)
{res.inspect, inp, res}.each { |text| puts "--------", text }

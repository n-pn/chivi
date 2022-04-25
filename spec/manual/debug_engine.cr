require "../../src/cvmtl/mt_core"

inp = ARGV[0]? || "电竞第一美女？"
dic = ARGV[1]? || "mvttgmnj"

mtl = CV::MtCore.generic_mtl(dic)
res = mtl.cv_plain(inp)
{res.inspect, inp, res}.each { |text| puts "--------", text }
puts CV::MtCore.cv_hanviet(inp)

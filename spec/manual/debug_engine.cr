require "../../src/cvmtl/mt_core"

inp = ARGV[0]? || "【扫书】后宫-YY-玄幻-综漫—绿奴卫道士退散"
dic = ARGV[1]? || "combine"

mtl = CV::MtCore.generic_mtl(dic)
res = mtl.cv_plain(inp)
{res.inspect, inp, res}.each { |text| puts "--------", text }

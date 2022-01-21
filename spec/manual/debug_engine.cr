require "../../src/cvmtl/mt_core"

inp = ARGV[0]? || "\"厉鬼\"的主角"
dic = ARGV[1]? || "w5d6vmqr"

mtl = CV::MtCore.generic_mtl(dic)
res = mtl.cv_plain(inp)

{res.inspect, inp, res}.each do |text|
  puts "--------", text
end

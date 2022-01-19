require "../../src/cvmtl/mt_core"

inp = ARGV[0]? || "怎么带着一群猪队友把一群神一样！"
dic = ARGV[1]? || "w5d6vmqr"

mtl = CV::MtCore.generic_mtl(dic)
res = mtl.cv_plain(inp)

{res.inspect, inp, res}.each do |text|
  puts "--------", text
end

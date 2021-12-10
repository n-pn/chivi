require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("fnjqty5r")

inp = "答案正确，赵丽娅就抱着电脑和八音盒走了：“加油！今晚你可能没那么轻松哦。挺住！”"
res = GENERIC.cv_plain(inp)

[res.inspect, inp, res].each do |text|
  puts "--------", text
end

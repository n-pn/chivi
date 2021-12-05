require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("7zx48vye")

inp = "那放出魅惑金光的金币堆，将两个钱箱放进自己的储藏柜，带着衣服先给爱丽莎与卡帝亚送了过去。"
res = GENERIC.cv_plain(inp)

[res.inspect, inp, res].each do |text|
  puts "--------", text
end

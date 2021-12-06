require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("fnjqty5r")

inp = "源清素和姬宫十六夜在旅馆门口的防波堤上，朝海滩扔飞碟，“兔兔”飞快地跑过去衔回来。"
res = GENERIC.cv_plain(inp)

[res.inspect, inp, res].each do |text|
  puts "--------", text
end

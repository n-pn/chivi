require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("combine")

inp = "那就不知道那个怪物的同伴，究竟是"
res = GENERIC.cv_title_full(inp)

{res.inspect, inp, res}.each do |text|
  puts "--------", text
end

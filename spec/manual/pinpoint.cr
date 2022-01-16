require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("82qjzt29")

inp = "（完）"
res = GENERIC.cv_title_full(inp)

{res.inspect, inp, res}.each do |text|
  puts "--------", text
end

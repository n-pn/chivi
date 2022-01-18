require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("m1596jjw")

inp = "瞪大，"
res = GENERIC.cv_plain(inp)

{res.inspect, inp, res}.each do |text|
  puts "--------", text
end

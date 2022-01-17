require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("combine")

inp = "徐向阳关心地问道"
res = GENERIC.cv_title_full(inp)

{res.inspect, inp, res}.each do |text|
  puts "--------", text
end

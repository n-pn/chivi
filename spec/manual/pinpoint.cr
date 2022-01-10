require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("82qjzt29")

inp = "看着被绷带包成木乃尹般的双手"
res = GENERIC.cv_title_full(inp)

{res.inspect, inp, res}.each do |text|
  puts "--------", text
end

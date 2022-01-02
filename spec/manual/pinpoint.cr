require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("82qjzt29")

inp = "像斯摩格这样的海军"
res = GENERIC.cv_plain(inp)

{res.inspect, inp, res}.each do |text|
  puts "--------", text
end

require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("7zx48vye")

inp = "她的美令人痴迷"
res = GENERIC.cv_plain(inp)

{res.inspect, inp, res}.each do |text|
  puts "--------", text
end

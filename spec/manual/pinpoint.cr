require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("fnjqty5r")

inp = "想我怎么写"
res = GENERIC.cv_plain(inp)

[res.inspect, inp, res].each do |text|
  puts "--------", text
end

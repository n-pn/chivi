require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("6y9qp333")

inp = "非常的爱你"
res = GENERIC.cv_plain(inp)

{res.inspect, inp, res}.each do |text|
  puts "--------", text
end

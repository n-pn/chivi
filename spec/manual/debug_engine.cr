require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("6y9qp333")

inp = "古巴比伦、古埃及、古印度、古中国、古希腊"
res = GENERIC.cv_plain(inp)

{res.inspect, inp, res}.each do |text|
  puts "--------", text
end

require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("6y9qp333")

inp = "只有呼啸而过的风声来回打转"
res = GENERIC.cv_title_full(inp)

{res.inspect, inp, res}.each do |text|
  puts "--------", text
end

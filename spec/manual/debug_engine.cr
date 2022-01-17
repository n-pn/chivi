require "../../src/cvmtl/mt_core"

GENERIC = CV::MtCore.generic_mtl("combine")

inp = "忍不住仔细打量起那张扭曲的脸庞"
res = GENERIC.cv_plain(inp)

{res.inspect, inp, res}.each do |text|
  puts "--------", text
end

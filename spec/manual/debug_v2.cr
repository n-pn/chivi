require "../../src/mtlv2/engine"

inp = ARGV[0]? || "“不能接受关乎身体的交易？”"
dic = ARGV[1]? || "-mvttgmnj"

mtl = MtlV2::Engine.generic_mtl(dic)
res = mtl.cv_plain(inp)

res.inspect(STDOUT, 0)
puts "------"
puts inp
puts "------"
puts res.to_txt
puts "------"
puts MtlV2::Engine.cv_hanviet(inp)

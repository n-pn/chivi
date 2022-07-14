require "../../src/mtlv1/mt_core"

input = ARGV[0]? || "这种“大聪明”"
dname = ARGV[1]? || "-mvttgmnj"
uname = ARGV[1]? || ""

mtl = CV::MtCore.generic_mtl(dname, uname)
res = mtl.cv_plain(input)

res.inspect(STDOUT, 0)
puts "------"
puts input
puts "------"
puts res.to_s
puts "------"
puts CV::MtCore.cv_hanviet(input)

require "../../src/mtlv1/mt_core"

input = ARGV[0]? || "这种“大聪明”"
dname = ARGV[1]? || "-mvttgmnj"
uname = ARGV[1]? || ""

mtl = CV::MtCore.generic_mtl(dname, uname)
res = mtl.cv_title_full(input)

res.inspect(STDOUT)
puts [input, res.to_txt, CV::MtCore.cv_hanviet(input)].join("\n-----\n")

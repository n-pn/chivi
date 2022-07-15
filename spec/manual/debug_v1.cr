require "../../src/mtlv1/mt_core"

input = ARGV[0]? || "这种“大聪明”"
dname = ARGV[1]? || "-mvttgmnj"
uname = ARGV[1]? || ""

mtl = CV::MtCore.generic_mtl(dname, uname)
res = mtl.cv_plain(input)

res.inspect(STDOUT)
puts "------"
puts input
puts "------"
puts res.to_txt
puts "------"
puts [res.to_mtl]
puts "------"
puts CV::MtCore.cv_hanviet(input)

# # \\tChương 26ǀ0ǀ0ǀ4\\t: ǀ0ǀ4ǀ1\\tĐào chủ nhiệmǀ3ǀ5ǀ3\\t \\tvẫn làǀ2ǀ8ǀ2\\t \\tanh em tốtǀ2ǀ10ǀ3\\n\\tCóǀ1ǀ0ǀ1\\t 〈0\\t⟨ǀ0ǀ1ǀ1\\tHoả Lực
# "\tCóǀ1ǀ0ǀ1\t 〈0\t⟨ǀ0ǀ1ǀ1\tHoả Lực Thiếu Niên Vươngǀ3ǀ2ǀ5\t⟩ǀ0ǀ7ǀ1〉\t "
# "\tCóǀ1ǀ0ǀ1\t \t〈5\t\t〈6\t\ttrụ cộtǀ2ǀ13ǀ2\t\thài lòngǀ2ǀ11ǀ2〉\t\t〈6\"

# \tCóǀ1ǀ0ǀ1\t 〈0\t⟨ǀ0ǀ1ǀ1\tHoả Lực Thiếu Niên Vươngǀ3ǀ2ǀ5\t⟩ǀ0ǀ7ǀ1〉\t 〈6〈7\ttrụ cộtǀ2ǀ13ǀ2\t \thài lòngǀ2ǀ11ǀ2〉\t 〈7\tđánh hạǀ2ǀ8ǀ2\tǀ0ǀ10ǀ1〉〉\t,ǀ0ǀ15ǀ1\t 〈5〈3\tmấyǀ1ǀ22ǀ1\t 〈4\tnhàǀ2ǀ23ǀ1\t \tđài truyền hìnhǀ2ǀ24ǀ3〉〉

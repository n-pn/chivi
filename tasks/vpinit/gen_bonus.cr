output = Hash(String, Int32).new(0)

DIR = "_db/vpinit"
File.each_line("#{DIR}/corpus/xinghua-all.txt").each do |word|
  output[word] += 10
end

File.write("#{DIR}/bonus.tsv")

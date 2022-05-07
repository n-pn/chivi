bonus = Hash(String, Int32).new(0)

def read_keys(file : String)
  File.read_lines(file).reject!(&.empty?).map(&.split('\t', 2).first).uniq!
end

read_keys("_db/vpinit/corpus/xinhua-all.txt").each do |key|
  bonus[key] += 10
end

read_keys("var/vpdicts/v1/fixed/trungviet.tsv").each do |key|
  bonus[key] += 20
end

read_keys("var/vpdicts/v1/fixed/cc_cedict.tsv").each do |key|
  bonus[key] += 20
end

File.open("_db/vpinit/term-bonus.tsv", "w") do |io|
  bonus.each do |key, val|
    io.puts "#{key}\t#{val}"
  end
end

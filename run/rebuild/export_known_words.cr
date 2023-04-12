require "json"
require "sqlite3"

def export(files : Array(String), name : String, encoding = "UTF-8", &)
  items = [] of String

  files.each_with_index(1) do |file, idx|
    puts "- #{idx}/#{files.size}: #{file}"

    File.each_line(file, encoding: encoding) do |line|
      next unless word = yield line
      items << word
    end
  end

  items.uniq!

  out_path = "var/cvmtl/known/#{name}.tsv"

  puts "exported to #{out_path}, items: #{items.size}"
  File.write(out_path, items.join('\n'))
end

DIR = "var/cvmtl"
# export(["#{DIR}/bdtmp/raw-books.tsv"], "bdlac", &.split('\t').first?)
# export(["#{DIR}/cvmtl/input/Tiếng trung hiện đại từ dùng nhiều/现代汉语常用词表[以词频排序] - Tiếng Trung hiện đại danh sách từ thường dùng (theo số lần xuất hiện).txt"], "common", encoding: "GB18030", &.split('\t')[1]?)

# files = Dir.glob("#{DIR}/cvmtl/input/THUOCL/*.txt")
# export(files, "thuocl", &.split('\t').first?)

# files = Dir.glob("#{DIR}/cvmtl/input/词典/通用词/*.txt")
# export(files, "common2", &.split('\t').first?)

# DIC_DIR = "#{DIR}/cvmtl/input/chinese-dictionary"

# json = File.read "#{DIC_DIR}/character/char_base.json"
# data = Array(NamedTuple(char: String)).from_json(json)

# ondict = data.map(&.[:char])

# json = File.read "#{DIC_DIR}/word/word.json"
# data = Array(NamedTuple(word: String)).from_json(json)
# data.each { |item| ondict << item[:word] }

# json = File.read "#{DIC_DIR}/idiom/idiom.json"
# data = Array(NamedTuple(word: String)).from_json(json)
# data.each { |item| ondict << item[:word] }

# File.each_line("#{DIR}/system/cc-cedict.tsv") do |line|
#   next unless word = line.split('\t')[1]?
#   ondict << word
# end

# File.each_line("#{DIR}/system/lacviet-mtd.txt") do |line|
#   next unless word = line.split('=').first?
#   ondict << word
# end

# ondict.uniq!
# out_path = "var/inits/known/ondict.tsv"

# puts "exported to #{out_path}, items: #{ondict.size}"
# File.write(out_path, ondict.join('\n'))

# DB.open("sqlite3:var/dicts/defns/all_terms.dic") do |db|
#   words = db.query_all "select zh from terms", as: String
#   File.write("var/inits/known/corpus.tsv", words.join('\n'))
# end

# export(["var/dicts/inits/count-by-books.tsv"], "texsmart", &.split('\t').first?)

files = Dir.glob("var/cvmtl/known/*.tsv")

output = Set(String).new

files.each do |file|
  next if file.ends_with?("all-known.tsv")
  output.concat File.read_lines(file)
end

puts output.size
File.write("var/cvmtl/known/all-known.tsv", output.join('\n'))

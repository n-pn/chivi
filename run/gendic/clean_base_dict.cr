require "sqlite3"
require "colorize"

DIR = "var/dicts/outer"

valids = File.read_lines("#{DIR}/valids.tsv").map!(&.split('\t').first)

DIC = DB.open("sqlite3:var/dicts/mtdic/base.dic")
at_exit { DIC.close }

words = DIC.query_all "select zstr, xpos from defns", as: {String, String}

invalids = words.select do |word, xpos|
  next false if word.in?(valids)
  next unless xpos.includes?("NR")

  word.matches?(/\d+/)


  # word.matches?(/^[零〇一二两三四五六七八九十百千万亿兆]{2,}$/i)
  # word.matches?(/^[零〇一二两三四五六七八九十百千万亿]+(gb|kg|g|l|m|km|hz|分|米|万|亿|助攻|吨|寸|元|岁)(以上|以内|多)?$/i)
  # word.matches?(/^[零〇一二两三四五六七八九十百千万亿]+(以上|以内|多)$/i)
  # word.matches?(/^[零〇一二两三四五六七八九十百千万亿]+(条|米)(以上|以内|多)?$/i)
  # word.matches? /^百分之[零〇一二两三四五六七八九十百千万亿]/
end


invalids.each do |word, xpos|
  puts "#{word}\t#{xpos}".colorize.red
end

puts invalids.size
exit 0 if invalids.empty?

puts "enter to delete: "
gets

invalids.each do |(invalid, _)|
  DIC.exec "delete from defns where zstr = $1", invalid
end

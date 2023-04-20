require "sqlite3"
require "colorize"

DIR = "var/mtdic/outer"

valids = File.read_lines("#{DIR}/valids.tsv").map!(&.split('\t').first)

DIC = DB.open("sqlite3:var/mtdic/fixed/common-main.dic")
at_exit { DIC.close }

words = DIC.query_all "select zstr, xpos from defns", as: {String, String}

invalids = words.select do |zstr, xpos|
  next false if zstr.in?(valids)
  next false unless zstr.matches?(/[零〇一二两三四五六七八九十百千万亿兆]美元$/)

  puts "#{zstr}\t#{xpos}".colorize.red
  true
end

puts invalids.size
exit 0 if invalids.empty?

puts "enter to delete: "
gets

invalids.each do |(invalid, _)|
  DIC.exec "delete from defns where zstr = $1", invalid
end

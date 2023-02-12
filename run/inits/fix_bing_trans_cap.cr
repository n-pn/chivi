require "sqlite3"

db_path = "sqlite3:var/dicts/defns/all_terms.dic"

db = DB.open(db_path)

fixes = {} of String => String

db.query_each "select zh, vi, bi from terms where bi <> '' order by rowid asc" do |rs|
  zh, vi, bi = rs.read(String, String, String)

  next if bi == zh || bi == vi
  next if bi[0].in?('0'..'9')

  vi_list = vi.split('\t')
  next if vi_list.includes?(bi)

  next unless bi == bi.capitalize

  next unless vi_list.empty? || vi_list.any? { |x| x == x.downcase }

  puts "#{zh}\t#{vi_list.join('|')}\t#{bi}"
end

# require "../../src/mt_sp/util/btran_api"
# fixes.keys.each_slice(100) do |group|
#   puts group

#   SP::Btran.translate(group, no_cap: true).each do |(zh, vi)|
#     File.open("var/dicts/defns/bing-tmp.tsv", "a") do |file|
#       file << zh << '\t' << vi.sub('\t', '|') << '\t' << fixes[zh]? << '\n'
#     end
#   end
# end

# File.each_line("var/dicts/defns/bing-tmp.tsv") do |line|
#   next if line.empty?
#   key, val, _ = line.split('\t')
#   fixes[key] = val
# end

puts fixes
puts "fixing: #{fixes.size}"

db.exec "begin"

fixes.each do |zh, bi|
  db.exec "update terms set bi = ? where zh = ?", bi, zh
end

db.exec "commit"
db.close

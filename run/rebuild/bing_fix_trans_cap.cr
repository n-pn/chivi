require "sqlite3"

propers = Set(String).new
File.each_line("var/dicts/_temp/all-proper.tsv") do |line|
  propers << line.split('\t', 2).first
end

db = DB.open("sqlite3:var/dicts/defns/all_terms.dic")

fixes = {} of String => String

db.query_each "select zh, vi, bi from terms where bi <> '' order by rowid asc" do |rs|
  zh, vi, bi = rs.read(String, String, String)
  next if bi == zh || vi.includes?(bi)
  next if bi[0].in?('0'..'9') || bi == bi.downcase
  # next if vi != vi.downcase

  # next if bi <> bi.capitalize
  # next if propers.includes?(zh)

  puts "#{zh}\t#{vi}\t#{bi}"
  fixes[zh] = vi.empty? ? bi : "#{vi}\t#{bi}"
end

require "../../src/mtapp/service/btran_api"

fixes.keys.each_slice(100) do |group|
  SP::Btran.translate(group, no_cap: true).each do |(zh, vi)|
    db.exec "update terms set bi = $1 where zh = $2", vi, zh

    File.open("var/dicts/defns/bing-tmp.tsv", "a") do |file|
      file << zh << '\t' << vi.sub('\t', '|') << '\t' << fixes[zh]? << '\n'
    end
  end
end

db.close

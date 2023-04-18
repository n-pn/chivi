require "sqlite3"
require "colorize"

SEEDS_DB = DB.open("sqlite3:var/chaps/seed-infos.db?journal_mode=WAL&synchronous=normal")
at_exit { SEEDS_DB.close }

record Seed, wn_id : Int32, sname : String, chap_total : Int32 do
  include DB::Serializable
end

sql = "select wn_id, sname, chap_total from seeds"
seeds = SEEDS_DB.query_all(sql, as: Seed)

max_chaps = seeds.group_by(&.wn_id).map do |wn_id, items|
  {wn_id, items.max_of(&.chap_total)}
end

index_map = Dir.glob("var/anlzs/texsmart/idx/*.tsv").map do |file|
  {File.basename(file).split('-', 2).first.to_i, file}
end.to_h

total_chaps = 0
missing_count = 0

max_chaps.each do |wn_id, chap_total|
  next unless idx_file = index_map[wn_id]?

  chap_total = 386 if chap_total > 386
  total_chaps += chap_total

  ch_nos = File.read_lines(idx_file).map(&.split('\t', 2).first.to_i).uniq!
  next if ch_nos.size >= chap_total

  missings = (1..chap_total).to_a - ch_nos
  puts "#{wn_id} misisng: #{missings.size}".colorize.red
  missing_count += missings.size
end

puts "missing chaps: #{missing_count}/#{total_chaps}"

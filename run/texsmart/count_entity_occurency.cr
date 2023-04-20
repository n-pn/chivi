require "sqlite3"

DIR = "var/anlzs/texsmart/out"

counter = Hash({String, String}, Int32).new(0)
select_sql = "select zstr, ztag, count from terms where \"type\" > 300"

files = Dir.children(DIR).sort_by! { |x| File.basename(x, ".db").to_i }

files.each do |path|
  puts path

  DB.open("sqlite3:#{DIR}/#{path}") do |db|
    db.query_each select_sql do |rs|
      zstr, ztag, occu = rs.read(String, String, Int32)
      counter[{zstr, ztag}] &+= occu
    end
  end
end

puts counter.size

upsert_sql = "replace into ent_freqs (form, etag, freq) values ($1, $2, $3)"

db_path = "var/mtdic/fixed/defns/ent_freqs.dic"
DB.open("sqlite3:#{db_path}?journal_mode=WAL&synchronous=normal") do |db|
  db.exec "begin"

  counter = counter.to_a.sort_by(&.[1].-)

  counter.each do |(zstr, ztag), occu|
    db.exec upsert_sql, zstr, ztag, occu
  end

  db.exec "commit"
end

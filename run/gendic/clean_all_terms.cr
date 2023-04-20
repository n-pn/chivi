require "sqlite3"

db_path = "sqlite3:var/mtdic/fixed/defns/all_terms.dic"

db = DB.open(db_path)

to_delete = [] of String

rejects = {
  # /^[\d零〇一二两三四五六七八九十百千]+月[\d零〇一二两三四五六七八九十百千]+$/,
  # /^[\d零〇一二两三四五六七八九十百千]+月[\d零〇一二两三四五六七八九十百千]+号$/,
  /.+美元$/,
  /.+英镑$/,
}

db.query_each "select zh from terms order by rowid asc" do |rs|
  zh = rs.read(String)
  # next unless zh =~ /^第[零〇一二两三四五六七八九十百千]+[章条节]$/
  # next unless zh =~ /^[\d零〇一二两三四五六七八九十百千]+[章条节]$/

  next unless rejects.any?(&.matches?(zh))

  to_delete << zh
end

puts to_delete

puts "delete: #{to_delete.size}"
gets

db.exec "begin"

to_delete.each do |zh|
  db.exec "delete from terms where zh = ?", zh
end

db.exec "commit"
db.close

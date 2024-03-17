require "../src/mt_sp/data/zv_word"
require "../src/mt_ai/core/qt_core"

require "../src/_data/zr_db"

# v1_defns = DB.open "sqlite3:var/mt_db/v1_defns.db3?immutable=1" do |db|
#   query = "select zstr, vstr from defns where vstr <> '' and d_id <> -11 and d_id <> -10"
#   db.query_all query, as: {String, String}
# end

# v1_defns.uniq!.select! do |zstr, vstr|
#   zstr.matches?(/\p{Han}/)
# end

# puts v1_defns.size

# SP::SqTran.db.open_tx do |db|
#   v1_defns.each do |zstr, vstr|
#     SP::SqTran.new(zstr, vstr, "qt_v1").upsert!(db: db)
#   end
# end

query = <<-SQL
  select zstr, vstr from zvterm
  where vstr <> '' and (d_id = 11 or d_id % 10 > 2 or d_id = 110 or d_id = 120)
  SQL

v2_defns = ZR_DB.query_all query, as: {String, String}

v2_defns.uniq!.select! do |zstr, vstr|
  zstr.matches?(/\p{Han}/)
end

puts v2_defns.size

SP::ZvWord.db.open_tx do |db|
  v2_defns.each do |zstr, vstr|
    SP::ZvWord.new(zstr, vstr, "qt_v2").upsert!(db: db)
  end
end

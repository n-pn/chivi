require "../src/mt_sp/data/zv_name"

require "../src/_util/char_util"
require "../src/_util/viet_util"

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

nhimmeo = DB.open("sqlite3:var/mtdic/hirachiba.db", &.query_all "select zh, vi from Names where vi is not null", as: {String, String})

nhimmeo.map! do |zstr, vstr|
  {CharUtil.canonize(zstr), VietUtil.fix_tones(vstr)}
end

puts nhimmeo.size

SP::ZvName.db.open_tx do |db|
  nhimmeo.each do |zstr, vstr|
    SP::ZvName.new(zstr, vstr, "nhimmeo").upsert!(db: db)
  end
end

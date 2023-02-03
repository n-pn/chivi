require "pg"
require "../src/cv_env"

db = DB.open(CV_ENV.database_url)
at_exit { db.close }

changes = [] of Tuple(String, Int64)

db.exec "alter table nvinfos drop constraint if exists nvinfos_bslug_key"

db.query_each "select id, bslug from nvinfos" do |rs|
  id, bslug = rs.read(Int64, String)
  changes << {bslug.sub(/^\w+/, ""), id}
end

db.exec "begin transaction"
changes.each do |bslug, id|
  db.exec "update nvinfos set bslug = $1 where id = $2", bslug, id
end

db.exec "commit"
db.exec "create index nvinfos_bslug_idx on nvinfos(bslug)"

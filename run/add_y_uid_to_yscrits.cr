require "pg"
require "../src/cv_env"

PG_DB = DB.open(CV_ENV.database_url)
at_exit { PG_DB.close }

id_map = {} of Int32 => Int32

PG_DB.query_each "select id::int, y_uid::int from ysusers order by y_uid asc" do |rs|
  id_map[rs.read(Int32)] ||= rs.read(Int32)
end

PG_DB.exec "begin transaction"
id_map.each do |c_uid, y_uid|
  puts "#{c_uid} => #{y_uid}"
  PG_DB.exec "update yslists set y_uid = $1 where ysuser_id = $2", y_uid, c_uid
  PG_DB.exec "update yscrits set y_uid = $1 where ysuser_id = $2", y_uid, c_uid
  PG_DB.exec "update ysrepls set y_uid = $1 where ysuser_id = $2", y_uid, c_uid
end
PG_DB.exec "commit"

require "pg"
require "../../src/cv_env"

PG_DB = DB.open(CV_ENV.database_url)
at_exit { PG_DB.close }

id_map = {} of Int32 => Int32

PG_DB.query_each "select id::int, yu_id::int from ysusers order by yu_id asc" do |rs|
  id_map[rs.read(Int32)] ||= rs.read(Int32)
end

PG_DB.exec "begin transaction"
id_map.each do |c_uid, yu_id|
  puts "#{c_uid} => #{yu_id}"
  PG_DB.exec "update yslists set yu_id = $1 where ysuser_id = $2", yu_id, c_uid
  PG_DB.exec "update yscrits set yu_id = $1 where ysuser_id = $2", yu_id, c_uid
  PG_DB.exec "update ysrepls set yu_id = $1 where ysuser_id = $2", yu_id, c_uid
end
PG_DB.exec "commit"

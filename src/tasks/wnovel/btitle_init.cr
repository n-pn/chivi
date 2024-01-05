ENV["CV_ENV"] ||= "production"
require "../../_data/_data"

PGDB.exec <<-SQL
  insert into btitles(bt_zh, bt_hv, bt_vi)
  select btitle_zh, btitle_hv, btitle_vi from wninfos
  where id >= 10
  order by wninfos.id asc
  on conflict(bt_zh) do nothing
SQL

PGDB.exec <<-SQL
  insert into btitles(bt_zh, bt_hv)
  select btitle_zh, btitle_vi from rmstems
  on conflict(bt_zh) do nothing
SQL

PGDB.exec <<-SQL
  insert into btitles(bt_zh)
  select btitle from ysbooks
  on conflict(bt_zh) do nothing
SQL

# old_map = PGDB.query_all("select bt_zh, bt_vi from btitles", as: {String, String}).to_h
# new_map = PGDB.query_all("select btitle_zh, btitle_vi from wninfos", as: {String, String}).to_h

# saving = new_map.reject! { |k, v| k == v || old_map[k]? == v }

# PGDB.transaction do |tx|
#   saving.each do |k, v|
#     tx.connection.exec "update btitles set bt_vi = $1 where bt_zh = $2", v, k
#   end
# end

# puts saving.size

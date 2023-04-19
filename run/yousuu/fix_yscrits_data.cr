require "pg"
require "colorize"
require "../../src/cv_env"

PG_DB = DB.open(CV_ENV.database_url)
at_exit { PG_DB.close }

DICT_MAP = {} of Int32 => Int32

dict_sql = "select id::int, nvinfo_id::int from ysbooks order by voters desc"
PG_DB.query_each dict_sql do |rs|
  DICT_MAP[rs.read(Int32)] = rs.read(Int32)
end

progress = 0

DICT_MAP.each do |y_bid, wn_id|
  progress += 1
  puts "- <#{progress}/#{DICT_MAP.size}> #{wn_id}".colorize.blue

  PG_DB.exec "update yscrits set nvinfo_id = $1 where ysbook_id = $2", wn_id, y_bid
end

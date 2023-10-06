require "pg"
require "colorize"
require "../../src/cv_env"

PG_DB = DB.connect(CV_ENV.database_url)
at_exit { PG_DB.close }

DICT_MAP = [] of {String, String}

query = "select id::int, nvinfo_id::int from ysbooks order by voters desc"
input = PG_DB.query_all(query, as: {Int32, Int32})

index = 0

input.each_slice(50) do |slice|
  puts "- <#{index * 50}/#{input.size}>".colorize.blue
  index &+= 1

  PG_DB.exec "begin"

  slice.each do |yb_id, wn_id|
    PG_DB.exec "update yscrits set nvinfo_id = $1 where ysbook_id = $2", wn_id, yb_id
  end

  PG_DB.exec "commit"
end

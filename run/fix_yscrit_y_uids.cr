require "pg"
require "../src/cv_env"

PG_DB = DB.open(CV_ENV.database_url)
at_exit { PG_DB.close }

PG_DB.exec "begin transaction"

File.each_line("var/ysraw/crit_users.tsv") do |line|
  cols = line.split('\t')
  next unless cols.size > 1
  y_cid, y_uid = cols

  PG_DB.exec "update yscrits set y_uid = $1 where origin_id = $2", y_uid.to_i, y_cid
end

PG_DB.exec "commit"

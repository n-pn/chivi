require "pg"
require "../src/cv_env"

PG_DB = DB.open(CV_ENV.database_url)
at_exit { PG_DB.close }

MAP = {} of Int32 => String

File.each_line("var/ysraw/crit_users.tsv") do |line|
  cols = line.split('\t')
  next unless cols.size > 2

  _, y_uid, zname = cols
  MAP[y_uid.to_i] ||= zname
end

puts "users: #{MAP.size}"

PG_DB.exec "begin transaction"
MAP.each do |y_uid, zname|
  PG_DB.exec "update ysusers set zname = $1 where y_uid = $2", zname, y_uid
  PG_DB.exec "update ysusers set y_uid = $1 where zname = $2", y_uid, zname
end

PG_DB.exec <<-SQL
  delete from ysusers a
  where a.id <> (select min(b.id) from ysusers b
                 where a.y_uid = b.y_uid);
SQL

PG_DB.exec "commit"

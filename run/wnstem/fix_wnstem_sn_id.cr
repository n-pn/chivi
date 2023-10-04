require "pg"
require "sqlite3"

ENV["CV_ENV"] = "production"
require "../../src/cv_env"

PGDB = DB.connect(CV_ENV.database_url)
at_exit { PGDB.close }

WN_SQL = <<-SQL
  select wn_id, sname, s_bid from wnseeds
  where sname like '~%' and s_bid like '~%'
SQL

CH_SQL = "select ch_no, cksum from chinfos where cksum <> ''"

input = PGDB.query_all WN_SQL, as: {Int32, String, String}

input.each do |wn_id, sname, s_bid|
  old_db = "var/stems/wn#{sname}/#{s_bid}-cinfo.db3"
  new_db = "var/stems/wn#{sname}/#{wn_id}-cinfo.db3"

  File.rename(old_db, new_db) if File.file?(old_db)

  old_dir = "var/texts/wn#{sname}/#{s_bid}"
  new_dir = "var/texts/wn#{sname}/#{wn_id}"

  File.rename(old_dir, new_dir) if File.directory?(old_dir)

  PGDB.exec "update wnseeds set s_bid = $1 where wn_id = $2 and sname = $3", wn_id.to_s, wn_id, sname
  puts "#{s_bid} => #{wn_id}"
end

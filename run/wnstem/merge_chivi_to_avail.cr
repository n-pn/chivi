require "pg"
require "sqlite3"

ENV["CV_ENV"] = "production"
require "../../src/cv_env"

PGDB = DB.connect(CV_ENV.database_url)
at_exit { PGDB.close }

WN_SQL = <<-SQL
  select distinct(wn_id) from wnseeds
  where sname = '~chivi' or sname = '~avail' and chap_total > 0
SQL

CH_SQL = <<-SQL
  replace into chinfos( ch_no, ztitle, vtitle, zchdiv, vchdiv, spath, rlink, cksum, sizes, mtime, uname, _flag)
  select * from inp.chinfos
SQL

def merge(old_db, new_db)
  DB.open("sqlite3:#{new_db}") do |db|
    db.exec "attach database 'file:#{old_db}' as inp"
    db.exec CH_SQL
  rescue ex
    puts ex
  end
end

input = PGDB.query_all(WN_SQL, as: {Int32})

input.each do |wn_id|
  old_db = "var/stems/wn~chivi/#{wn_id}-cinfo.db3"
  new_db = "var/stems/wn~avail/#{wn_id}-cinfo.db3"
  next unless File.file?(old_db)

  puts "#{old_db} => #{new_db}"
  if File.file?(new_db)
    merge(old_db, new_db)
  else
    File.rename(old_db, new_db)
  end

  # old_dir = "var/texts/wn#{sname}/#{s_bid}"
  # new_dir = "var/texts/wn#{sname}/#{wn_id}"

  # File.rename(old_dir, new_dir) if File.directory?(old_dir)

  # PGDB.exec "update wnseeds set s_bid = $1 where wn_id = $2 and sname = $3", wn_id.to_s, wn_id, sname
  # puts "#{s_bid} => #{wn_id}"
end

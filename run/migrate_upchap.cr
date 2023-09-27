require "sqlite3"

DB_ROOT = "var/up_db/stems"

files = Dir.glob("#{DB_ROOT}/**/*.db3").reject!(&.ends_with?("-cinfo.db3"))

files.each do |file|
  puts file

  sname = File.basename(File.dirname(file))
  up_id = File.basename(file, ".db3")

  DB.open "sqlite3:#{file}" do |db|
    db.exec "update chinfos set spath = ($1 || '/' || $2 || '/' || ch_no)", sname, up_id
  end

  File.rename(file, file.sub(".db3", "-cinfo.db3"))
end

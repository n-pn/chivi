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

  out_file = file.sub(".db3", "-cinfo.db3")
  File.delete?(out_file)
  File.rename(file, out_file)
end

# files = Dir.glob("#{DB_ROOT}/**/*.db3").select!(&.ends_with?("-cinfo.db3"))

# files.each do |file|
#   total = DB.open "sqlite3:#{file}" do |db|
#     db.query_one("select count(ch_no) from chinfos", as: Int32)
#   rescue ex
#     puts ex
#     0
#   end

#   next if total > 0
#   puts file
#   File.delete(file)
# end

require "log"
require "sqlite3"

INP = "/2tb/zroot/zdata"

def migrate(db_path)
  DB.open("sqlite3:#{db_path}") do |db|
    db.exec "alter table czdata add column zsize int not null default 0"
    db.exec "alter table czdata add column zorig text not null default ''"
  end

  File.rename(db_path, db_path.sub(".db3", ".dbx"))
end

Dir.each_child(INP) do |sname|
  files = Dir.glob("#{INP}/#{sname}/*-zdata.db3")
  puts "#{sname}: #{files.size}"

  files.each do |db_path|
    puts db_path
    migrate(db_path)
  rescue ex
    File.open("#{INP}/err.log", "a", &.puts(db_path))
  end
end

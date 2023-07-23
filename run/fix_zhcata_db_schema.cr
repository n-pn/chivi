require "sqlite3"

DIR = "/2tb/var.chivi/zchap/globs"

def update_db(db_path : String)
  DB.open("sqlite3:#{db_path}") do |db|
    db.exec "alter table chaps rename column wcount to chlen"
    db.exec "alter table chaps add column xxh32 int not null default 0"
  rescue err
    puts err
  end
end

def update_all(sname : String)
  paths = Dir.glob("#{DIR}/#{sname}/*.db3")
  paths.each do |db_path|
    puts db_path
    update_db(db_path)
  end
end

Dir.children(DIR).each do |sname|
  spawn update_all(sname)
end

sleep 10

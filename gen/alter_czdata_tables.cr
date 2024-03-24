require "sqlite3"

DIR = "/2tb/zroot/wn_db"

def alter_tables(sname : String, plock = 1)
  db_paths = Dir.glob("#{DIR}/#{sname}/*-zdata.db3")

  alter_sql =
    db_paths.each do |db_path|
      DB.open("sqlite3:#{db_path}") do |db|
        db.exec "alter table czdata drop column plock" rescue nil
        db.exec "alter table czdata add column _lock int not null default #{plock}" rescue nil
        db.exec "alter table czdata rename column zorig to _user" rescue nil
        db.exec "alter table czdata rename column zlink to _note" rescue nil
      end

      puts "#{db_path} altered!"
    end
end

users = Dir.children(DIR).select(&.starts_with?('@'))

snames = ARGV.reject(&.starts_with?('-'))
snames.concat(users) if ARGV.includes?("--users")

plock = ENV["PLOCK"]?.try(&.to_i) || 1

snames.each do |sname|
  alter_tables(sname, plock)
end

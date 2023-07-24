require "sqlite3"

DIR = "/2tb/var.chivi/zchap/globs"

def update_db(db_path : String)
  DB.open("sqlite3:#{db_path}") do |db|
    db.exec <<-SQL
      create table if not exists bumps(
        id int primary key,

        total_chap int not null default 0,
        latest_cid varchar not null default '',

        status_str varchar not null default '',
        update_str varchar not null default '',

        uname varchar not null default '',
        rtime bigint not null default 0
      );
      SQL

    db.exec("alter table chaps rename column wcount to chlen") rescue nil
    db.exec("alter table chaps add column xxh32 int not null default 0") rescue nil
    db.exec("alter table chaps add column cpath varchar not null default ''") rescue nil
  rescue err
    puts err
  end
end

def update_all(sname : String)
  paths = Dir.glob("#{DIR}/#{sname}/*.db3")
  paths.each do |db_path|
    # puts db_path
    update_db(db_path)
  end
end

Dir.children(DIR).each do |sname|
  spawn update_all(sname)
end

sleep 10

require "sqlite3"

DIR = "/2tb/var.chivi/zchap/globs"

def update_db(db_path : String)
  DB.open("sqlite3:#{db_path}") do |db|
    db.exec "drop table if exists bumps"
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS rlogs(
        total_chap int NOT NULL DEFAULT 0,
        latest_cid varchar NOT NULL DEFAULT '',
        ---
        status_str varchar NOT NULL DEFAULT '',
        update_str varchar NOT NULL DEFAULT '',
        ---
        uname varchar NOT NULL DEFAULT '',
        rtime bigint NOT NULL DEFAULT 0
      );
    SQL

    # db.exec("alter table chaps rename column wcount to chlen") rescue nil
    # db.exec("alter table chaps add column xxh32 int not null default 0") rescue nil
    # db.exec("alter table chaps add column cpath varchar not null default ''") rescue nil


  rescue err
    puts err
  end
end

db_paths = Dir.glob("#{DIR}/*/*.db3")

workers = Channel({String, Int32}).new(db_paths.size)

threads = 12
results = Channel(Int32).new(threads)

threads.times do
  spawn do
    loop do
      db_path, idx = workers.receive
      update_db(db_path)
      results.send(idx)
    end
  end
end

db_paths.each_with_index(1) { |path, idx| workers.send({path, idx}) }

db_paths.size.times do
  idx = results.receive
  puts "- #{idx}/#{db_paths.size} done" if idx % 100 == 0
end

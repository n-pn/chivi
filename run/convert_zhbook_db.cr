require "sqlite3"

INP = "var/books/infos"
OUT = "var/wn/books"

def init_db(db : DB::Database)
  db.exec "pragma journal_mode = WAL"
  db.exec "drop table if exists books"

  db.exec <<-SQL
    create table books (
      id int not null primary key,

      btitle varchar not null default '',
      author varchar not null default '',

      intro varchar not null default '',
      genre varchar not null default '',
      cover varchar not null default '',

      status_str varchar not null default '',
      update_str varchar not null default '',

      chap_count int not null default 0,
      latest_cid int not null default 0,

      rtime bigint not null default 0,
      _flag smallint not null default 0
    )
  SQL
end

def import(db : DB::Database, old_name : String)
  db.exec "attach database '#{INP}/#{old_name}.db' as src"
  db.exec <<-SQL
    insert into books (id, btitle, author, intro, genre, cover, status_str, update_str, chap_count, latest_cid, rtime)
    select cast(snvid as int), btitle, author, bintro, genres, bcover, status_str, update_str, chap_total, last_schid, updated_at
    from src.zhbooks
  SQL
end

def convert(name : String)
  DB.open "sqlite3:#{OUT}/#{name}.db" do |db|
    init_db(db)
    import(db, name)
  end
end

Dir.children(INP).each do |file|
  puts file
  name = File.basename(file, ".db")
  convert File.basename(name)
rescue err
  puts err
end

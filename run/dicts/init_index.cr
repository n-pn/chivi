require "db"
require "pg"
require "sqlite3"
require "amber"

inp_db = DB.open(Amber.settings.database_url)
out_db = DB.open("sqlite3://var/dicts/index.db")
at_exit { inp_db.close; out_db.close }

def init_db(db : DB::Database, reset = false)
  db.exec "drop table if exists dicts;" if reset

  db.exec <<-SQL
    create table if not exists dicts(
      id integer primary key,

      name varchar not null unique,
      slug varchar not null default '',

      label varchar not null default '',
      intro varchar not null default '',

      dsize integer not null default 0,
      mtime integer not null default 0
    )
  SQL

  db.exec <<-SQL
    create index if not exists mtime_idx on dicts(mtime);
  SQL

  db.exec <<-SQL
    insert into dicts(id, name, slug, label, intro)
    values (1, 'global', '-tong-hop', 'Thông dụng', 'Từ điển dùng chung cho tất cả các bộ truyện')
  SQL
end

init_db(out_db, reset: false)
out_db.exec "begin transaction"

query = "select id, bhash, bslug, vname from nvinfos where id > 0 order by id asc"
inp_db.query_each(query) do |rs|
  id, name, slug, label = rs.read(Int64, String, String, String)

  intro = "Từ điển riêng cho bộ truyện [#{label}]"
  out_db.exec <<-SQL, args: [-id.to_i, "-" + name, slug, label, intro]
    insert or ignore into dicts(id, name, slug, label, intro)
    values (?, ?, ?, ?, ?)
  SQL
end

out_db.exec "commit"

require "../../src/appcv/ys_book"

require "sqlite3"

db = DB.open("sqlite3:./var/ysapp/map_id.db")
at_exit { db.close }

db.exec <<-SQL
  create table map (
    ysid int primary key,
    cvid int not null default 0,
    hash varchar not null default '',
    name varchar not null default '',
    slug varchar not null default ''
  );

  create index nv_index on map (nv);
  create index hash_index on map (hash);
SQL

db.exec "begin transaction"

CV::Ysbook.query.each do |ysbook|
  nvbook = ysbook.nvinfo
  args = [ysbook.id, nvbook.id, nvbook.bhash, nvbook.vname, nvbook.bslug]

  db.exec <<-SQL, args: args
    insert into map (ysid, cvid, hash, name, slug) values (?, ?, ?, ?, ?);
  SQL
end

db.exec "commit"

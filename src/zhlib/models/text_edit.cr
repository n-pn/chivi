require "crorm/model"
require "crorm/sqlite3"

class ZH::TextEdit
  include Crorm::Model

  field id : Int32, primary: true

  field sname : String
  field s_bid : Int32

  field s_cid : Int32
  field ch_no : Int32

  field patch : String
  field uname : String

  field ctime : Int64 = Time.utc.to_unix
  field _flag : Int32 = 0

  def save!(db = @@db)
    fields, values = get_changes
    db.insert(@@table, fields, values)
  end

  ###

  @@table = "text_edits"
  class_getter db = Crorm::Sqlite3::Repo.new("var/chaps/#{@@table}.db", init_sql)

  def self.init_sql
    <<-SQL
    create table if not exists #{@@table} (
      id integer primary key,
      --
      sname varchar not null,
      s_bid integer not null,
      --
      s_cid integer not null,
      ch_no integer not null,
      --
      patch text not null,
      --
      uname varchar not null default '',
      ctime integer not null default 0,
      --
      _flag integer not null default 0
    );

    create index if not exists #{@@table}_user_idx on #{@@table}(uname, _flag);
    create index if not exists #{@@table}_book_idx on #{@@table}(sname, s_bid);
    SQL
  end
end

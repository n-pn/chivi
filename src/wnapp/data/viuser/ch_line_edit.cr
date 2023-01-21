require "crorm/model"
require "crorm/sqlite3"

class WN::ChLineEdit
  include Crorm::Model

  field id : Int32, primary: true

  field sname : String
  field s_bid : Int32

  field s_cid : Int32
  field ch_no : Int32

  field part_no : Int32
  field line_no : Int32

  field patch : String
  field uname : String

  field ctime : Int64 = Time.utc.to_unix
  field _flag : Int32 = 0

  def save!(db = @@db)
    fields, values = get_changes
    db.insert(@@table, fields, values)
  end

  ###

  @@table = "line_edits"
  class_getter db = Crorm::Sqlite3::Repo.new(self.db_path, self.init_sql)

  @[AlwaysInline]
  def self.db_path
    "var/chaps/#{@@table}.db"
  end

  def self.init_sql(table_name = @@table)
    <<-SQL
    create table if not exists #{table_name} (
      id integer primary key,
      --
      sname varchar not null,
      s_bid integer not null,
      --
      s_cid integer not null,
      ch_no integer not null,
      --
      part_no integer not null,
      line_no integer not null,
      --
      patch text not null,
      --
      uname varchar not null default '',
      ctime integer not null default 0,
      --
      _flag integer not null default 0
    );

    create index if not exists #{table_name}_user_idx on #{table_name}(uname, _flag);
    create index if not exists #{table_name}_book_idx on #{table_name}(sname, s_bid);
    SQL
  end
end

require "crorm/model"
require "crorm/sqlite3"

struct WN::ChTextEdit
  include Crorm::Model
  @@table = "text_edits"

  field id : Int32, primary: true

  field sname : String
  field s_bid : Int32

  field s_cid : Int32
  field ch_no : Int32

  field patch : String
  field uname : String

  field ctime : Int64 = Time.utc.to_unix
  field _flag : Int32 = 0

  def initialize(@sname, @s_bid, @s_cid, @ch_no, @patch, @uname)
  end

  def create!(repo : SQ3::Repo = self.class.repo)
    fields, values = db_changes()
    repo.insert(@@table, fields, values)
  end

  ###

  class_getter repo : SQ3::Repo { SQ3::Repo.new(db_path, init_sql) }

  def self.db_path(name : String = "full-edits")
    "var/chaps/users/#{name}.db"
  end

  def self.init_sql(table : String = @@table)
    <<-SQL
    create table if not exists #{table} (
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

    create index if not exists user_idx on #{table}(uname, _flag);
    create index if not exists book_idx on #{table}(sname, s_bid);
    SQL
  end
end

require "crorm/model"
require "crorm/sqlite"

struct WN::ChLineEdit
  class_getter db_path = "var/zchap/zline-edits.db"

  class_getter init_sql = <<-SQL
    create table if not exists line_edits (
      id integer not null primary key,
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

    create index if not exists user_idx on line_edits(uname, _flag);
    create index if not exists book_idx on line_edits(sname, s_bid);

    SQL

  ###

  include Crorm::Model
  schema "line_edits", :sqlite

  # field id : Int32, pkey: true, auto: true, skip: true

  field sname : String = ""
  field s_bid : Int32 = 0

  field s_cid : Int32 = 0
  field ch_no : Int32 = 0

  field part_no : Int32 = 0
  field line_no : Int32 = 0

  field patch : String = ""
  field uname : String = ""

  field ctime : Int64 = Time.utc.to_unix
  field _flag : Int32 = 0

  def initialize(@sname, @s_bid, @s_cid, @ch_no, @part_no, @line_no, @patch, @uname)
  end
end

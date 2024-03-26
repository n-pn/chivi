require "crorm"

struct WN::ChtextLineEdit
  class_getter db_path = "/srv/chivi/wn_db/chtext-line-edit.db"

  class_getter init_sql = <<-SQL
    create table if not exists line_edits (
      id integer not null primary key,
      --
      wn_id integer not null,
      sname varchar not null,
      --
      ch_no integer not null,
      fpath integer not null,
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
    create index if not exists book_idx on line_edits(wn_id, sname);

    SQL

  ###

  include Crorm::Model
  schema "line_edits", :sqlite

  # field id : Int32, pkey: true, auto: true, skip: true

  field wn_id : Int32
  field sname : String

  field ch_no : Int32 = 0
  field fpath : String = ""

  field part_no : Int32 = 0
  field line_no : Int32 = 0

  field patch : String = ""
  field uname : String = ""

  field ctime : Int64 = Time.utc.to_unix
  field _flag : Int32 = 0

  def initialize(@wn_id, @sname, @ch_no, @fpath, @part_no, @line_no, @patch, @uname)
  end
end

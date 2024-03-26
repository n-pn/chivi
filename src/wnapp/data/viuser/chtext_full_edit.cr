require "crorm"

struct WN::ChtextFullEdit
  class_getter db_path = "/srv/chivi/wn_db/chtext-full-edit.db"

  class_getter init_sql = <<-SQL
    create table if not exists full_edits (
      id integer not null primary key,
      --
      wn_id varchar not null,
      sname varchar not null,
      --
      ch_no integer not null,
      fpath varchar not null,
      --
      uname varchar not null default '',
      ctime integer not null default 0,
      --
      _flag integer not null default 0
    );

    create index if not exists user_idx on full_edits(uname, _flag);
    create index if not exists book_idx on full_edits(wn_id, sname);
    SQL

  ###

  include Crorm::Model
  schema "full_edits", :sqlite

  # field id : Int32, pkey: true, auto: true

  field wn_id : Int32
  field sname : String = ""

  field ch_no : Int32 = 0
  field fpath : String = ""

  field uname : String = ""
  field ctime : Int64 = Time.utc.to_unix

  field _flag : Int32 = 0

  def initialize(@wn_id, @sname, @ch_no, @fpath, @uname)
  end

  ###
end

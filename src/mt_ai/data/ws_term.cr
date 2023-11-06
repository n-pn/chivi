require "crorm"

struct MT::Wsterm
  DIR = "var/mt_db"

  def self.db_path(type : String = "global")
    "#{DIR}/#{type}-wseg.db3"
  end

  class_getter init_sql : String = <<-SQL
    CREATE TABLE IF NOT EXISTS wsterms (
      d_id int NOT NULL,
      zstr text NOT NULL,
      --
      wprio int not null default 2,
      ntype text,
      --
      z_out text,
      v_out text,
      --
      uname text NOT NULL DEFAULT '',
      mtime int NOT NULL DEFAULT 0,
      _flag int NOT NULL DEFAULT 0,
      --
      primary key(d_id, zstr)
    ) strict, without rowid;
  SQL

  ###

  include Crorm::Model
  schema "wsterms", :sqlite, multi: true

  field d_id : Int32, pkey: true
  field zstr : String, pkey: true

  field wprio : Int32 = 2
  field ntype : String? = nil

  field z_out : String? = nil
  field v_out : String? = nil

  field uname : String = ""
  field mtime : Int32 = 0

  def initialize(@d_id, @zstr, @wprio, @ntype, @z_out, @v_out)
  end
end

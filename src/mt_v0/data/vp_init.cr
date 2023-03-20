require "crorm"
require "crorm/sqlite3"

class MT::MtDefn
  include Crorm::Model
  @@table = "defns"

  class_getter repo : SQ3::Repo do
    SQ3::Repo.new(db_path, init_sql, ttl: 3.minutes)
  end

  @[AlwaysInline]
  def self.db_path
    "var/dicts/base.dic"
  end

  def self.init_sql(table = @@table)
    <<-SQL
      CREATE TABLE IF NOT EXISTS #{table} (
        "id" integer NOT NULL PRIMARY KEY, -- id < 0 mean deleted
        "zstr" varchar NOT NULL, -- normalized chinese input
        --
        "upos" varchar NOT NULL DEFAULT '', -- user defined part of speech
        "tran" varchar NOT NULL default '', -- user defined translation
        "prio" integer not null default 3, -- user defined priority
        --
        "xpos" varchar NOT NULL DEFAULT '', -- derived part of speech
        "prop" varchar NOT NULL default '', -- derived properties
        --
        "mtime" bigint NOT NULL DEFAULT 0, -- last modification time
        "uname" varchar NOT NULL DEFAULT '', -- last modified by
        --
        "_flag" integer NOT NULL DEFAULT 0 -- reusable field for mass manipulation
      );

      CREATE INDEX IF NOT EXISTS zstr_idx ON #{table}("zstr");
      CREATE INDEX IF NOT EXISTS tags_idx ON #{table}("tags");
      CREATE INDEX IF NOT EXISTS user_idx ON #{table}("uname");

      -- enable wal mode on default
      pragma journal_mode = WAL;

    SQL
  end

  ###

  field id : Int32, primary: true

  field zstr : String = ""
  field tags : String = ""
  field mtls : String = ""

  field ptag : String = ""
  field prio : Int32 = 0

  field raw_tags : String = "{}" # json data
  field raw_mtls : String = "{}" # json data

  field mtime : Int64 = 0
  field uname : String = ""

  field _flag : Int32 = 0
end

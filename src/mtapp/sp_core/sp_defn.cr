require "sqlite3"
require "../shared/utils"

class MT::SpDefn
  include DB::Serializable
  class_getter table = "defns"

  property zstr : String
  property vstr : String

  property _fmt : Int32 = 0

  property uname : String = ""
  property mtime : Int32 = 0

  def initialize(@zstr, @vstr, @_fmt = 0, @uname = "", @mtime = Utils.mtime)
  end

  def save!(db : DB::Database | DB::Connection)
    db.exec <<-SQL, @zstr, @vstr, @_fmt, @uname, @mtime
      insert into "defns" ("zstr", "vstr", "_fmt", "uname", "mtime")
      values ($1, $2, $3, $4, $5)
      on conflict("zstr") do update set
        "vstr" = excluded.vstr,
        "_fmt" = excluded._fmt,
        "uname" = excluded.uname,
        "mtime" = excluded.mtime
    SQL
  end

  ######

  # return path for database
  @[AlwaysInline]
  def self.db_path(dname : String)
    "var/mtdic/fixed/spdic/#{dname}.dic"
  end

  # open database for reading/writing
  def self.open_db(dname : String, &)
    db_path = self.db_path(dname)
    connection = "sqlite3:#{db_path}?journal_mode=WAL&synchronous=normal"
    DB.open(connection) { |db| yield db }
  end

  # open database with transaction for writing
  def self.open_tx(dname : String, &)
    open_db(dname) do |db|
      db.exec "begin"
      yield db
      db.exec "commit"
    end
  end

  def self.init_db(dname : String, reset : Bool = false)
    open_db(dname) do |db|
      db.exec "drop table if exists defns" if reset

      db.exec <<-SQL
        create table if not exists defns (
          "zstr" varchar primary key,
          "vstr" varchar not null,
          "_fmt" integer not null default 0,
          --
          "uname" varchar not null default '',
          "mtime" bigint not null default 0,
          "_flag" smallint not null default 0
        );
      SQL
    end
  end

  def self.load_data(dname : String, &)
    open_db(dname) do |db|
      db.query_each("select zstr, vstr from defns") do |rs|
        yield rs.read(String), rs.read(String)
      end
    end
  end
end

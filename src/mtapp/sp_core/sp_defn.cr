require "sqlite3"
require "crorm/model"
require "../shared/utils"

class MT::SpDefn
  include Crorm::Model
  schema "defns"

  field zstr : String, pkey: true
  field vstr : String

  field _fmt : Int32 = 0

  field uname : String = ""
  field mtime : Int32 = 0

  def initialize(@zstr, @vstr, @_fmt = 0, @uname = "", @mtime = Utils.mtime)
  end

  ######

  def self.db
    raise "invalid"
  end

  # return path for database
  @[AlwaysInline]
  def self.db_path(dname : String)
    "var/mtdic/fixed/spdic/#{dname}.dic"
  end

  # open database for reading/writing
  def self.db_open(dname : String, &)
    open_db(db_path(dname)) { |db| yield db }
  end

  # open database with transaction for writing
  def self.tx_open(dname : String, &)
    open_tx(db_path(dname)) { |db| yield db }
  end

  class_getter init_sql = <<-SQL
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

  def self.load_data(dname : String, &)
    open_db(db_path(dname)) do |db|
      db.query_each("select zstr, vstr from defns") do |rs|
        yield rs.read(String), rs.read(String)
      end
    end
  end
end

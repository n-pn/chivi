require "sqlite3"
require "crorm/model"
require "../shared/utils"

class MT::SpDefn
  include Crorm::Model
  schema "defns", multi: true

  field zstr : String, pkey: true
  field vstr : String

  field _fmt : Int32 = 0

  field uname : String = ""
  field mtime : Int32 = 0

  def initialize(@zstr, @vstr, @_fmt = 0, @uname = "", @mtime = Utils.mtime)
  end

  ###

  # return path for database
  @[AlwaysInline]
  def self.db_path(dname : String)
    "var/mtdic/fixed/spdic/#{dname}.dic"
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
    self.db(dname).open_ro do |db|
      db.query_each("select zstr, vstr from defns") do |rs|
        yield rs.read(String), rs.read(String)
      end
    end
  end
end

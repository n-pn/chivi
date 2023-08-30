require "crorm"

class AI::MtTerm
  class_getter init_sql = <<-SQL
    create table terms(
      zstr varchar not null,
      cpos varchar not null default '_',

      vstr varchar not null default '',
      pecs varchar not null default '',

      uname varchar not null default '',
      mtime bigint not null default 0,

      icpos int not null default 0,
      ipecs int not null default 0,

      _flag int not null default 0,

      primary key (zstr, cpos)
    )
    SQL

  def self.db_path(dname : String)
    "var/mtapp/mt_ai/#{dname}.db3"
  end

  ###

  include Crorm::Model
  schema "terms", :sqlite, multi: true

  field zstr : String, pkey: true
  field cpos : String, pkey: true

  field vstr : String = ""
  field pecs : String = ""

  field uname : String = ""
  field mtime : Int64 = 0

  field icpos : Int32 = 0
  field ipecs : Int32 = 0

  field _flag : Int32 = 0

  def initialize(@zstr, @cpos = "_", @vstr = "", @pecs = "")
  end

  ###

  def self.all_defs(dname : String)
    db(dname).open_ro do |db|
      output = {} of String => Hash(String, String)

      db.query_each("select zstr, cpos, vstr from terms") do |rs|
        zstr = rs.read(String)
        cpos = rs.read(String)
        vstr = rs.read(String)

        entry = output[zstr] ||= {} of String => String

        entry[cpos] = vstr
        entry["_"] ||= vstr
      end

      output
    end
  end
end

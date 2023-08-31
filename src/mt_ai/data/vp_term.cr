require "crorm"
require "./vp_pecs"

class AI::VpTerm
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

  def self.db_path(dname : String, type : String = "db3")
    "var/mtdic/mt_ai/#{dname}.#{type}"
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
end

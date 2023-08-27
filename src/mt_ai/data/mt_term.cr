require "crorm"

class AI::MtTerm
  class_getter init_sql = <<-SQL
    create table terms(
      zstr varchar not null,
      ptag varchar not null default '_',

      vstr varchar not null default '',
      attr varchar not null default '',

      uname varchar not null default '',
      mtime bigint not null default 0,

      _flag int not null default 0,

      primary key (zstr, ptag)
    )
    SQL

  def self.db_path(dname : String)
    "var/mtapp/mt_ai/#{dname}.db3"
  end

  ###

  include Crorm::Model
  schema "terms", :sqlite, multi: true

  field zstr : String, pkey: true
  field ptag : String, pkey: true

  field vstr : String = ""
  field attr : String = ""

  field uname : String = ""
  field mtime : Int64 = 0

  field _flag : Int32 = 0

  def initialize(@zstr, @ptag = "_", @vstr = "", @attr = "")
  end
end

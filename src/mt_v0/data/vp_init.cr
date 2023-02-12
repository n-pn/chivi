require "crorm"
require "crorm/sqlite3"

class M1::DbDefn
  include Crorm::Model
  @@table = "terms"

  class_getter repo = Crorm::Sqlite3::Repo.new(db_path, init_sql)

  @[AlwaysInline]
  def self.db_path
    "var/dicts/init.dic"
  end

  def self.init_sql
    {{ read_file("#{__DIR__}/sql/init_dict.sql") }}
  end

  ###

  field id : Int32, primary: true

  field zstr : String = ""
  field tran : String = ""

  field ctag : String = ""
  field _ord : Int32 = 0

  field tran_by : String = ""
  field ctag_by : String = ""

  field _flag : Int32 = 0
end

require "crorm"
require "crorm/sqlite3"

class MT::VpInit
  include Crorm::Model
  @@table = "terms"

  class_getter repo : SQ3::Repo { SQ3::Repo.new(db_path, init_sql, ttl: 3.minutes) }

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

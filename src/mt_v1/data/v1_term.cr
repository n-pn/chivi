require "crorm"
require "crorm/sqlite3"

class M1::DbTerm
  include Crorm::Model
  include DB::Serializable::NonStrict

  class_getter table : String = "terms"

  def self.repo(name : String = "_main")
    SQ3::Repo.new(db_path(name), init_sql)
  end

  @[AlwaysInline]
  def self.db_path(name : String)
    "var/mtdic/users/#{name}_v1.dic"
  end

  def self.init_sql
    {{ read_file("#{__DIR__}/sql/terms_v1.sql") }}
  end

  ###

  field id : Int32, primary: true
  field dic : Int32 = 0

  field key : String = ""
  field val : String = ""

  field etag : Int32 = 0
  field epos : Int64 = 0_u64

  field cost : Int32 = 0
end

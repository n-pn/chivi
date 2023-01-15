require "crorm"
require "crorm/sqlite3"

class M2::DbTerm
  include Crorm::Model
  @@table = "terms"

  field dic : Int32

  field key : String
  field val : String

  field ptag : Int32 = 0
  field attr : Int32 = 0
  field wght : Int32 = 0

  field _lock : Int32 = 0

  def save!(repo)
    fields, values = self.get_changes
    repo.insert(@@table, fields, values, :replace)
  end

  ###########

  class_getter base_repo = Crorm::Sqlite3::Repo.new(db_path("_base"), init_sql)
  class_getter temp_repo = Crorm::Sqlite3::Repo.new(db_path("_temp"), init_sql)

  USERS = {} of String => self

  def self.user_repo(uname : String)
    USERS[uname] ||= Crorm::Sqlite3::Repo.new(db_path(uname), init_sql)
  end

  @[AlwaysInline]
  def self.db_path(dname : String) : String
    "var/dicts/v2dic/#{dname}.dic"
  end

  def self.init_sql
    {{ read_file("#{__DIR__}/sql/terms_v2.sql") }}
  end
end

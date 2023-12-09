require "pg"
require "crorm"
require "../cv_env"

PGDB = DB.open(CV_ENV.database_url)
at_exit { PGDB.close }

ZR_DB = DB.open("postgres://postgres:postgres@localhost:5436/zroot")

module JsonConverter
  def to_db
    self.to_json
  end

  def self.to_db(val : self)
    val.to_json
  end

  def self.to_db(val : Nil)
    "{}"
  end

  def self.from_rs(rs : DB::ResultSet)
    new(rs.read(JSON::PullParser))
  end
end

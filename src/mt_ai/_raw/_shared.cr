require "db"
require "json"

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

  macro included
    def self.from_rs(rs : DB::ResultSet)
      new(rs.read(JSON::PullParser))
    end
  end
end

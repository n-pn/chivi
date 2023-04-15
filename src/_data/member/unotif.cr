require "crorm"
require "../_data"
require "../../_util/hash_util"

class CV::Unotif
  include Crorm::Model
  @@table = "unotifs"
  @@db : DB::Database = PGDB

  field id : Int32, primary: true
  field viuser_id : Int32

  field content : String = ""
  field details : String = ""
  field link_to : String = ""

  field reached_at : Time? = nil
  field created_at : Time = Time.utc

  def initialize(@viuser_id, @content, @details, @link_to)
  end

  def create!(db = @@db)
    stmt = <<-SQL
      insert into #{@@table}(viuser_id, content, details, link_to, created_at)
      values ($1, $2, $3, $4, $5)
    SQL

    db.exec stmt, @viuser_id, @content, @details, @link_to, @created_at
  end

  def self.count_unread(viuser_id : Int32)
    @@db.query_one(<<-SQL, viuser_id, as: Int32)
      select COALESCE(COUNT(*), 0)::int from #{@@table}
      where viuser_id = $1
      and reached_at is null
    SQL
  end

  def self.user_notifs(viuser_id : Int32, limit = 20, offset = 0)
    @@db.query_all <<-SQL, viuser_id, limit, offset, as: self
      select * from #{@@table}
      where viuser_id = $1
      limit $2 offset $3
      order by id desc
    SQL
  end
end

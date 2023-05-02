require "crorm"
require "../_data"
require "../../_util/hash_util"

struct CV::Unotif
  enum Action : Int16
    LikeGdroot = 0
    LikeGdrepl = 1
    LikeDtopic = 2

    LikeVicrit = 4
    LikeVilist = 5

    GetReplied = 20

    GetFollowed = 50

    TaggedInReply = 70
    TaggedInTopic = 71

    VcoinXchange = 100
    PriviUpgrade = 200

    def self.map_liking(target)
      case target
      when Rpnode then LikeGdrepl
      when Dtopic then LikeDtopic
      when Vicrit then LikeVicrit
      when Vilist then LikeVilist
      else             raise "unknown like action"
      end
    end
  end

  include Crorm::Model
  include DB::Serializable::NonStrict

  class_getter table = "unotifs"
  class_getter db : DB::Database = PGDB

  field id : Int32, primary: true
  field viuser_id : Int32

  field content : String = ""

  field action : Int16 = 0
  field object_id : Int32 = 0
  field byuser_id : Int32 = 0

  field reached_at : Time? = nil
  field created_at : Time = Time.utc

  def initialize(@viuser_id, @content,
                 action : Action, @object_id, @byuser_id,
                 @created_at = Time.utc)
    @action = action.value
  end

  def create!(db = @@db)
    stmt = <<-SQL
      insert into #{@@table}(
        viuser_id, content,
        "action", "object_id", "byuser_id",
        created_at
      ) values ($1, $2, $3, $4, $5, $6)
      returning *
    SQL

    db.query_one stmt, @viuser_id, @content,
      @action, @object_id, @byuser_id,
      @created_at,
      as: Unotif
  end

  def self.count_by_user(viuser_id : Int32)
    @@db.query_one(<<-SQL, viuser_id, as: Int32)
      select COALESCE(COUNT(*), 0)::int from #{@@table}
      where viuser_id = $1
    SQL
  end

  def self.mark_as_read(ids : Enumerable(Int32), reached_at : Time = Time.utc)
    Log.info { ids }
    @@db.query <<-SQL, reached_at, ids
      update #{@@table} set reached_at = $1
      where id = any ($2) and reached_at is null
    SQL
  end

  def self.count_unread(viuser_id : Int32)
    @@db.query_one(<<-SQL, viuser_id, as: Int32)
      select COALESCE(COUNT(*), 0)::int from #{@@table}
      where viuser_id = $1 and reached_at is null
    SQL
  end

  def self.user_notifs(viuser_id : Int32, limit = 20, offset = 0) : Array(self)
    @@db.query_all <<-SQL, viuser_id, limit, offset, as: self
      select * from #{@@table}
      where viuser_id = $1
      order by created_at desc
      limit $2 offset $3
    SQL
  end

  def self.user_unread_notifs(viuser_id : Int32, limit = 20, offset = 0) : Array(self)
    @@db.query_all <<-SQL, viuser_id, limit, offset, as: self
      select * from #{@@table}
      where viuser_id = $1 and reached_at is null
      order by created_at desc
      limit $2 offset $3
    SQL
  end

  def self.find(action : Action, object_id : Int32, byuser_id : Int32)
    @@db.query_one? <<-SQL, action.value, object_id, byuser_id, as: self
      select * from #{@@table}
      where "action" = $1 and object_id = $2 and byuser_id = $3
      limit 1
    SQL
  end

  def self.remove_notif(action : Action, object_id : Int32, byuser_id : Int32)
    @@db.query <<-SQL, action.value, object_id, byuser_id
      delete from #{@@table}
      where "action" = $1 and object_id = $2 and byuser_id = $3
      SQL
  end
end

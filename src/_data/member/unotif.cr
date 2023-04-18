require "crorm"
require "../_data"
require "../../_util/hash_util"

class CV::Unotif
  enum Action : Int16
    LikeRepl = 1
    LikeDtop = 2

    Replby = 20

    Saving = 50

    TaggedInRepl = 70
    TaggedInPost = 71

    VcoinEx = 100
    PriviUg = 200
  end

  include Crorm::Model
  class_getter table = "unotifs"
  class_getter db : DB::Database = PGDB

  field id : Int32, primary: true
  field viuser_id : Int32

  field action : Int16 = 0
  field object_id : Int32 = 0
  field byuser_id : Int32 = 0

  field content : String = ""
  field details : String = ""
  field link_to : String = ""

  field reached_at : Time? = nil
  field created_at : Time = Time.utc

  def initialize(@viuser_id,
                 action : Action, @object_id, @byuser_id,
                 @content, @details, @link_to,
                 @created_at = Time.utc)
    @action = action.value
  end

  def create!(db = @@db)
    stmt = <<-SQL
      insert into #{@@table}(
        viuser_id,
        "action", object_id, byuser_id,
        content, details, link_to,
        created_at
      ) values ($1, $2, $3, $4, $5, $6, $7, $8)
    SQL

    db.exec stmt, @viuser_id,
      @action, @object_id, @byuser_id,
      @content, @details, @link_to,
      @created_at
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

  def self.create_repl_notif(repl : Murepl)
    return if repl.touser_id == 0 || repl.touser_id == repl.viuser_id
    return if find(:replby, repl.id, repl.viuser_id)

    content, details, link_to = repl.gen_repl_notif

    unotif = Unotif.new(
      repl.touser_id,
      :replby, repl.id, repl.viuser_id,
      content, details.to_json, link_to,
      repl.created_at
    )
    puts unotif.to_pretty_json.colorize.green
    unotif.create!
  end

  def self.create_tagged_notif(repl : Murepl)
    return if repl.tagged_ids.empty?

    repl.tagged_ids.each do |tagged_id|
      memoir = Memoir.load(tagged_id, :murepl, repl.id)
      memoir.tagged_at = repl.utime
      memoir.save!
    end

    content, details, link_to = repl.gen_tagged_notif

    repl.tagged_ids.each do |tagged_id|
      next if tagged_id == repl.touser_id || tagged_id == repl.viuser_id
      return if find(:tagged_in_repl, repl.id, repl.viuser_id)

      unotif = CV::Unotif.new(
        tagged_id,
        :tagged_in_repl, repl.id, repl.viuser_id,
        content, details.to_json, link_to,
        repl.created_at
      )

      puts unotif.to_pretty_json.colorize.blue
      unotif.create!
    end
  end
end

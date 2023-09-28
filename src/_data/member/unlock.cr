require "../_data"

class CV::Unlock
  class_getter db : DB::Database = PGDB
  ###

  include Crorm::Model
  schema "unlocks", :postgres, strict: false

  field vu_id : Int32, pkey: true
  field ulkey : String, pkey: true

  field zsize : Int32 = 0
  field multp : Int16 = 0
  field vcoin : Int32 = 0

  field ctime : Int64 = Time.utc.to_unix
  field mtime : Int64 = Time.utc.to_unix
  field flags : Int32 = 0

  def initialize(@vu_id, @ulkey, @zsize = 0, @multp = 0_i16,
                 @vcoin = (zsize * multp * 0.01).to_i)
  end

  SAVE_SQL = <<-SQL
    insert into unlocks(vu_id, ulkey, zsize, multp, vcoin, ctime, mtime, flags)
    values ($1, $2, $3, $4, $5, $6, $7, $8)
    on conflict(vu_id, ulkey) do update set
      mtime = excluded.mtime,
      vcoin = unlocks.vcoin + excluded.vcoin,
      flags = unlocks.flags | excluded.flags
    returning *
    SQL

  def save!(db = @@db)
    db.query_one(SAVE_SQL, @vu_id, @ulkey, @zsize, @multp, @vcoin, @ctime, @mtime, @flags, as: self.class)
  end

  FIND_BY_UKEY_SQL = "select * from unlocks where vu_id = $1 and ulkey = $2 limit 1"

  def self.find(vu_id : Int32, ulkey : String)
    return if vu_id < 1
    @@db.query_one?(FIND_BY_UKEY_SQL, vu_id, ulkey, as: self)
  end

  def self.init(vu_id : Int32, ulkey : String)
    data = find(vu_id, ulkey) || new(vu_id, ulkey)
    data.tap(&.mtime = Time.utc.to_unix)
  end
end

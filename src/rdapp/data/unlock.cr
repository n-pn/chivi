require "../../_data/_data"
require "../../_data/member/xvcoin"

class RD::Unlock
  class_getter db : DB::Database = PGDB
  ###

  include Crorm::Model
  schema "unlocks", :postgres, strict: false

  field vu_id : Int32, pkey: true
  field ulkey : String, pkey: true

  field zsize : Int32 = 0
  field multp : Int16 = 0
  field vcoin : Int32 = 0

  field owner : Int32 = -1 # target who will receive vcoin
  field ctime : Int64 = Time.utc.to_unix

  def initialize(@ulkey, @zsize, @vu_id, @multp = 4_i16, @owner = -1)
    @vcoin = (zsize * multp * 0.01).to_i
  end

  SAVE_SQL = <<-SQL
    insert into unlocks(vu_id, ulkey, zsize, multp, vcoin, "owner", ctime)
    values ($1, $2, $3, $4, $5, $6, $7)
    on conflict(vu_id, ulkey) do update set
      "zsize" = excluded.zsize,
      "multp" = excluded.multp,
      "vcoin" = excluded.vcoin,
      "owner" = excluded.owner,
      "ctime" = excluded.ctime
    returning *
    SQL

  def unlock!(db = @@db) : Bool
    return false if @ulkey.empty? || @zsize == 0

    # TODO: convert vcoin to vnd
    amount = @vcoin / 1000
    remain = CV::Xvcoin.micro_transact(sender: @vu_id, target: @owner, amount: amount)

    return false unless remain && remain >= 0
    db.query_one(SAVE_SQL, @vu_id, @ulkey, @zsize, @multp, @vcoin, @owner, @ctime, as: self.class)

    true
  end

  FIND_BY_UKEY_SQL = "select * from unlocks where vu_id = $1 and ulkey = $2 limit 1"

  def self.find(vu_id : Int32, ulkey : String)
    return false if vu_id == 0
    @@db.query_one?(FIND_BY_UKEY_SQL, vu_id, ulkey, as: self)
  end

  CHECK_BY_UKEY_SQL = "select vcoin from unlocks where vu_id = $1 and ulkey = $2 limit 1"

  def self.unlocked?(vu_id : Int32, ulkey : String)
    return false if vu_id == 0
    @@db.query_one?(CHECK_BY_UKEY_SQL, vu_id, ulkey, as: Int32)
  end

  # def self.init(vu_id : Int32, ulkey : String)
  #   data = find(vu_id, ulkey) || new(vu_id, ulkey)
  #   data.tap(&.mtime = Time.utc.to_unix)
  # end
end

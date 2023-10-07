require "../../_data/_data"
require "../../_data/member/xvcoin"

class RD::Unlock
  class_getter db : DB::Database = PGDB
  ###

  include Crorm::Model
  schema "unlocks", :postgres, strict: false

  field vu_id : Int32, pkey: true
  field ulkey : String, pkey: true

  field owner : Int32 = 0 # target who will receive vcoin

  field zsize : Int32 = 0
  field multp : Int16 = 0
  field vcoin : Int32 = 0

  field ctime : Int64 = Time.utc.to_unix
  field mtime : Int64 = Time.utc.to_unix
  field flags : Int32 = 0

  def initialize(@vu_id, @ulkey, @owner, @zsize = 0, @multp = 0_i16,
                 @vcoin = (zsize * multp * 0.01).to_i)
  end

  SAVE_SQL = <<-SQL
    insert into unlocks(vu_id, ulkey, "owner", zsize, multp, vcoin, ctime, mtime, flags)
    values ($1, $2, $3, $4, $5, $6, $7, $8, $9)
    on conflict(vu_id, ulkey) do update set
      mtime = excluded.mtime,
      vcoin = unlocks.vcoin + excluded.vcoin,
      flags = unlocks.flags | excluded.flags
    returning *
    SQL

  def save!(db = @@db)
    db.query_one(SAVE_SQL, @vu_id, @ulkey, @owner, @zsize, @multp, @vcoin, @ctime, @mtime, @flags, as: self.class)
  end

  FIND_BY_UKEY_SQL = "select * from unlocks where vu_id = $1 and ulkey = $2 limit 1"

  def self.find(vu_id : Int32, ulkey : String)
    return if vu_id < 0
    @@db.query_one?(FIND_BY_UKEY_SQL, vu_id, ulkey, as: self)
  end

  CHECK_BY_UKEY_SQL = "select 1 from unlocks where vu_id = $1 and ulkey = $2 limit 1"

  def self.unlocked?(vu_id : Int32, ulkey : String)
    return false if vu_id < 0
    @@db.query_one?(CHECK_BY_UKEY_SQL, vu_id, ulkey, as: Int32).nil?.!
  end

  def self.init(vu_id : Int32, ulkey : String)
    data = find(vu_id, ulkey) || new(vu_id, ulkey)
    data.tap(&.mtime = Time.utc.to_unix)
  end

  def self.unlock(ustem : Upstem, cinfo : Chinfo, vu_id : Int32, p_idx : Int32)
    owner = ustem.viuser_id
    ulkey = ustem.crepo.part_name(cinfo, p_idx)

    zsize = cinfo.sizes[p_idx]? || 0
    return {nil, 0} if ulkey.empty? || zsize == 0

    unlock = new(vu_id: vu_id, ulkey: ulkey, owner: owner, zsize: zsize, multp: ustem.multp)

    # TODO: convert vcoin to vnd
    amount = unlock.vcoin / 1000

    remain = CV::Xvcoin.micro_transact(sender: vu_id, target: owner, amount: amount)
    remain ? {unlock.save!, remain} : {nil, 0}
  end

  def self.unlock(wstem : WN::Wnstem, cinfo : WN::Chinfo, vu_id : Int32, p_idx : Int32)
    ulkey = cinfo.part_name(wstem.sname, wstem.s_bid, p_idx)
    zsize = cinfo.sizes[p_idx]? || 0
    return {nil, 0} if ulkey.empty? || zsize == 0

    unlock = new(vu_id: vu_id, ulkey: ulkey, owner: -1, zsize: zsize, multp: wstem.multp)

    # TODO: convert vcoin to vnd
    amount = unlock.vcoin / 1000

    remain = CV::Xvcoin.micro_transact(sender: vu_id, target: -1, amount: amount)
    remain ? {unlock.save!, remain} : {nil, 0}
  end
end

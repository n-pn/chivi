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

  def initialize(crepo : Chrepo, cinfo : Chinfo,
                 @vu_id : Int32, p_idx : Int32,
                 @multp : Int16 = 4_i16, @owner : Int32 = -1)
    @ulkey = crepo.part_name(cinfo, p_idx)
    @zsize = cinfo.sizes[p_idx]? || 0
    @vcoin = (zsize * multp * 0.01).to_i
  end

  # def initialize(wstem : Wnstem, cinfo : Chinfo, @vu_id : Int32, p_idx : Int32)
  #   @ulkey = wstem.crepo.part_name(cinfo, p_idx)

  #   @zsize = cinfo.sizes[p_idx]? || 0
  #   @multp = wstem.multp
  #   @vcoin = (zsize * multp * 0.01).to_i
  # end

  # def initialize(rstem : Rmstem, cinfo : Chinfo, @vu_id : Int32, p_idx : Int32)
  #   @owner = -1
  #   @ulkey = rstem.crepo.part_name(cinfo, p_idx)

  #   @zsize = cinfo.sizes[p_idx]? || 0
  #   @multp = rstem.multp
  #   @vcoin = (zsize * multp * 0.01).to_i
  # end

  SAVE_SQL = <<-SQL
    insert into unlocks(vu_id, ulkey, "owner", zsize, multp, vcoin, ctime, mtime, flags)
    values ($1, $2, $3, $4, $5, $6, $7, $8, $9)
    on conflict(vu_id, ulkey) do update set
      mtime = excluded.mtime,
      vcoin = unlocks.vcoin + excluded.vcoin,
      flags = unlocks.flags | excluded.flags
    returning *
    SQL

  def unlock(db = @@db)
    return {nil, 0} if @ulkey.empty? || @zsize == 0

    # TODO: convert vcoin to vnd
    amount = @vcoin / 1000
    remain = CV::Xvcoin.micro_transact(sender: @vu_id, target: @owner, amount: amount)

    return {nil, 0} unless remain && remain >= 0

    saved = db.query_one(SAVE_SQL, @vu_id, @ulkey, @owner, @zsize, @multp, @vcoin, @ctime, @mtime, @flags, as: self.class)
    {saved, remain}
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

  # def self.init(vu_id : Int32, ulkey : String)
  #   data = find(vu_id, ulkey) || new(vu_id, ulkey)
  #   data.tap(&.mtime = Time.utc.to_unix)
  # end
end

require "../../_data/_data"
require "../../_data/member/xvcoin"
require "../../_data/member/uquota"

class RD::Unlock
  class_getter db : DB::Database = PGDB
  ###

  include Crorm::Model
  schema "unlocks", :postgres, strict: false

  field vu_id : Int32, pkey: true
  field ulkey : String, pkey: true

  field owner : Int32 = -1 # target who will receive vcoin
  field zsize : Int32 = 0

  field user_multp : Int16 = 0
  field real_multp : Int16 = 0

  field user_lost : Int32 = 0
  field owner_got : Int32 = 0

  field ctime : Int64 = Time.utc.to_unix

  def initialize(@vu_id, @ulkey,
                 @owner, @zsize,
                 @user_multp = 3_i16,
                 @real_multp = 3_i16)
    @user_lost = (zsize * user_multp) // 100
    @owner_got = (zsize * real_multp) // 100
  end

  # Return status code
  # - 414: empty field
  # - 415: not enough vcoin
  # - 0: no error
  def unlock!(db = @@db) : Int32
    return 414 if @ulkey.empty? || @zsize == 0

    # TODO: convert vcoin to integer

    if @user_lost > 0
      remain = CV::Xvcoin.subtract(vu_id: @vu_id, value: @user_lost / 1000)
      return 415 unless remain && remain >= 0

      uquota = Uquota.load(@vu_id)
      uquota.add_vcoin_bonus!(@user_lost * 100)
    end

    if @owner > 0 && @owner_got > 0
      CV::Xvcoin.increase(vu_id: @owner, value: @owner_got / 1000)
    end

    self.upsert!(db: db)

    0
  rescue ex
    Log.error(exception: ex) { self.to_json }
    500
  end

  FIND_BY_UKEY_SQL = "select * from unlocks where vu_id = $1 and ulkey = $2 limit 1"

  def self.find(vu_id : Int32, ulkey : String)
    return false if vu_id == 0
    @@db.query_one?(FIND_BY_UKEY_SQL, vu_id, ulkey, as: self)
  end

  CHECK_BY_UKEY_SQL = <<-SQL
    select owner from unlocks
    where vu_id = $1 and ulkey = $2
    limit 1
    SQL

  def self.unlocked?(vu_id : Int32, ulkey : String)
    return false if vu_id == 0
    @@db.query_one?(CHECK_BY_UKEY_SQL, vu_id, ulkey, as: Int32)
  end

  # def self.init(vu_id : Int32, ulkey : String)
  #   data = find(vu_id, ulkey) || new(vu_id, ulkey)
  #   data.tap(&.mtime = Time.utc.to_unix)
  # end

  def self.build_select_sql(ulkey : String? = nil, vu_id : Int32? = nil,
                            owner : Int32? = nil, order : String = "ctime")
    args = [] of String | Int32

    query = String.build do |sql|
      sql << "select * from #{@@schema.table} where 1 = 1"

      if ulkey
        args << ulkey
        sql << " and ulkey like $1 || '%'"
      end

      if vu_id
        args << vu_id
        sql << " and vu_id = $#{args.size}"
      end

      if owner
        args << owner
        sql << " and owner = $#{args.size}"
      end

      case order
      when "vcoin" then sql << " order by vcoin desc"
      when "zsize" then sql << " order by zsize desc"
      when "ctime" then sql << " order by ctime desc"
      end

      sql << " limit $#{args.size &+ 1} offset $#{args.size &+ 2}"
    end

    {query, args}
  end
end

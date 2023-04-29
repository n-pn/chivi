require "crorm/model"

require "./_data"
require "./_util"
require "../_raw/raw_ysrepl"

class YS::YsreplForm
  include Crorm::Model
  @@table = "ysrepls"
  @@db : DB::Database = PG_DB

  field id : Int32, auto: true
  field yr_id : Bytes, primary: true

  field yc_id : Bytes = "".hexbytes
  field yscrit_id : Int32 = 0

  field ysuser_id : Int32 = 0
  field touser_id : Int32 = 0 # to ysuser id

  field ztext : String = ""
  # field vhtml : String = ""

  field like_count : Int32 = 0
  field repl_count : Int32 = 0 # reply count, optional

  field info_rtime : Int64 = 0 # list checked at by minutes from epoch

  field created_at : Time = Time.utc
  field updated_at : Time = Time.utc

  def initialize(@yr_id)
  end

  def import!(raw : RawYsrepl, @info_rtime : Int64, vc_id : Int32? = nil)
    @yc_id = raw.yc_id.hexbytes
    @yscrit_id = vc_id || DBRepo.get_vc_id(@yc_id)

    @ysuser_id = raw.user.id
    @touser_id = raw.to_user.try(&.id) || 0

    @ztext = raw.ztext

    @like_count = raw.like_count
    @repl_count = raw.repl_count

    @created_at = raw.created_at
    @updated_at = raw.created_at

    self.upsert!
  end

  ##############

  @@load_stmt = stmt = String.build do |sql|
    sql << "select "
    @@load_fields.join(sql, ", ")
    sql << " from #{@@table} where yr_id = $1"
  end

  def self.load(yr_id : Bytes)
    PG_DB.query_one?(@@load_stmt, yr_id, as: self) || new(yr_id)
  end

  def self.bulk_upsert!(
    raws : Enumerable(RawYsrepl),
    rtime : Int64 = Time.utc.to_unix,
    vc_id : Int32? = nil
  )
    raws.map do |raw|
      self.load(raw.yr_id.hexbytes).import!(raw, rtime, vc_id)
    rescue ex
      Log.error(exception: ex) { raw.to_json }
    end
  end
end

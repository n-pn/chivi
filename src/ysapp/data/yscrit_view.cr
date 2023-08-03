require "crorm/model"

require "./_data"
require "./_util"
require "../_raw/raw_yscrit"

class YS::YscritForm
  class_getter db : DB::Database = PG_DB

  include Crorm::Model
  schema "yscrits", :postgres

  field id : Int32, auto: true
  field yc_id : Bytes, pkey: true
  # field yl_id : Bytes? = nil

  field nvinfo_id : Int32 = 0
  field ysbook_id : Int32 = 0

  field ysuser_id : Int32 = 0
  field yslist_id : Int32 = 0

  field ztext : String = ""
  field stars : Int32 = 0

  field ztags : Array(String) = [] of String

  field info_rtime : Int64 = 0_i64
  field repl_total : Int32 = 0
  field like_count : Int32 = 0

  field created_at : Time = Time.utc
  field updated_at : Time = Time.utc

  def initialize(@yc_id)
  end

  def import!(raw : RawYscrit, @info_rtime : Int64)
    @ysbook_id = raw.book.id
    @nvinfo_id = DBRepo.get_wn_id(@ysbook_id)

    @ysuser_id = raw.user.id

    @stars = raw.stars
    @ztags = raw.tags

    raw.ztext?.try { |z| @ztext = z }

    @like_count = raw.like_count
    @repl_total = raw.repl_total

    @created_at = raw.created_at
    @updated_at = raw.updated_at || raw.created_at

    self.upsert!
  end

  def self.load(yc_id : Bytes)
    get(yc_id, &.<< "where yc_id = $1") || new(yc_id)
  end

  def self.bulk_upsert!(raws : Array(RawYscrit), rtime : Int64 = Time.utc.to_unix)
    raws.compact_map do |raw|
      load(raw.yc_id.hexbytes).import!(raw, rtime)
    rescue ex
      Log.error(exception: ex) { raw.to_json }
    end
  end

  ####

  def self.update_repl_total(yc_id : Bytes, total : Int32, rtime : Int64)
    PG_DB.exec <<-SQL, total, rtime, yc_id
      update yscrits
      set repl_total = $1, repl_rtime = $2
      where yc_id = $3 and repl_total < $1
      SQL
  end

  def self.update_list_id(ids : Array(Int32), yl_id : Bytes, vl_id : Int32)
    PG_DB.exec <<-SQL, vl_id, yl_id, ids
      update yscrits
      set yslist_id = $1, yl_id = $2
      where id = any ($3)
      SQL
  end

  def self.update_list_id(yc_id : Bytes, yl_id : Bytes, vl_id : Int32)
    PG_DB.exec <<-SQL, vl_id, yl_id, yc_id
      update yscrits set yslist_id = $1, yl_id = $2 where yc_id = $3
      SQL
  end
end

require "crorm/model"

require "./_data"
require "./_util"
require "../_raw/raw_yscrit"

class YS::YscritForm
  include Crorm::Model

  @@table = "yscrits"
  @@db : DB::Database = PG_DB
  # @@conflicts = {"yc_id"}

  field yc_id : Bytes, primary: true
  field yl_id : Bytes? = nil

  field nvinfo_id : Int32 = 0
  field ysbook_id : Int32 = 0

  field ysuser_id : Int32 = 0
  field yslist_id : Int32 = 0

  field ztext : String = ""
  field stars : Int32 = 0

  field ztags : Array(String)

  field info_rtime : Int64
  field repl_total : Int32
  field like_count : Int32

  field created_at : Time
  field updated_at : Time

  def initialize(raw : RawYscrit, @info_rtime : Int64)
    @yc_id = raw.yc_id.hexbytes

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
  end

  def set_list_id(@yl_id : Bytes, @yslist_id = DBRepo.get_vl_id(yl_id))
  end

  def self.bulk_upsert!(
    raws : Array(RawYscrit),
    rtime : Int64 = Time.utc.to_unix,
    yl_id : Bytes? = nil, vl_id : Int32? = nil
  ) : Nil
    vl_id ||= DBRepo.get_vl_id(yl_id) if yl_id

    raws.each do |raw|
      form = new(raw, info_rtime: rtime)
      form.set_list_id(yl_id, vl_id) if yl_id && vl_id
      form.upsert!(@@db)
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

  def self.update_list_id(molist_id : Bytes)
    PG_DB.exec <<-SQL, molist_id
      update yscrits set yslist_id = (
        select id from yslists
        where yslists.yl_id = yscrits.yl_id
      ) where yl_id = $1
      SQL
  end
end

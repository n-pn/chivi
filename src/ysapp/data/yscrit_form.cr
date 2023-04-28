require "./_data"
require "./_util"

require "crorm/model"

require "../_raw/raw_yscrit"

class YS::YscritForm
  include Crorm::Model

  @@table = "yscrits"
  @@db : DB::Database = PG_DB

  field yc_id : Bytes #  mongodb objectid
  field yl_id : Bytes?

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

    if ztext = raw.ztext?
      @ztext = ztext
    end

    @like_count = raw.like_count
    @repl_total = raw.repl_total

    @created_at = raw.created_at
    @updated_at = raw.updated_at || raw.created_at
  end

  def set_list_id(@yl_id : Bytes, @yslist_id = DBRepo.get_vl_id(yl_id))
  end

  def upsert!(db = @@db)
    fields = self.db_fields

    stmt = String.build do |io|
      io << "insert into #{@@table} ("
      fields.join(io, ", ")

      io << ") values ("
      (1..fields.size).join(io, ", ") { |id, _| io << '$' << id }

      io << ") on conflict (yc_id) do update set "
      fields.reject("yc_id").join(io, ", ") do |field|
        io << field << " = excluded." << field
      end

      io << " returning id"
    end

    # Log.debug { stmt.colorize.blue }
    db.query_one(stmt, *db_values, as: Int32)
  end

  def self.bulk_upsert(raws : Array(RawYscrit),
                       rtime : Int64 = Time.utc.to_unix,
                       yl_id : Bytes? = nil, vl_id : Int32? = nil) : Nil
    vl_id ||= DBRepo.get_vl_id(yl_id) if yl_id

    raws.each do |raw|
      form = new(raw, info_rtime: rtime)
      form.set_list_id(yl_id, vl_id) if yl_id && vl_id
      form.upsert!(@@db)
    rescue ex
      Log.error(exception: ex) { raw }
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

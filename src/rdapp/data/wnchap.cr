require "crorm"
require "../../_util/chap_util"
require "../../_data/zr_db"

class RD::Wnchap
  class_getter db : DB::Database = ZR_DB
  ###

  include Crorm::Model
  schema "wnchap", :postgres

  field sname : String, pkey: true
  field sn_id : Int32, pkey: true
  field c_idx : Int32, pkey: true

  field ztitle : String = "" # chapter zh title name
  field zchdiv : String = "" # chapter zh division (volume) name

  field vtitle : String = "" # chapter vi title name
  field vchdiv : String = "" # chapter vi division (volume) name

  field mtime : Int32 = 0           # last modified at, optional
  field cksum : Bytes = "".hexbytes # if data existed this will be checksum of each chapter part
  field extra : String = ""         # last modified by, optional

  def initialize(@sname, @sn_id, @c_idx, @ztitle, @zchdiv, @extra = "", @mtime = 0)
  end

  def ztitle=(@ztitle : String)
    @vtitle = ""
  end

  def zchdiv=(@zchdiv : String)
    @vchdiv = ""
  end

  UPSERT_RAW_SQL = <<-SQL
    insert into wnchap(sname, sn_id, c_idx, ztitle, zchdiv, extra, mtime)
    values ($1, $2, $3, $4, $5, $6, $7)
    on conflict(sname, sn_id, c_idx) do update set
      ztitle = excluded.ztitle, vtitle =  '',
      zchdiv = excluded.zchdiv, vchdiv =  '',
      cksum = ''::bytea, extra = excluded.extra,
      mtime = GREATEST(excluded.mtime, wnchap.mtime)
  SQL

  def upsert_raw!(db = @@db)
    db.exec UPSERT_RAW_SQL, @sname, @sn_id, @c_idx, @ztitle, @zchdiv, @extra, @mtime
  end

  def to_json(jb : JSON::Builder)
    jb.object {
      jb.field "ch_no", @c_idx // 10

      jb.field "title", @vtitle.empty? ? @ztitle : @vtitle
      jb.field "chdiv", @vchdiv.empty? ? @zchdiv : @vchdiv

      jb.field "utime", @mtime * 60
    }
  end
end

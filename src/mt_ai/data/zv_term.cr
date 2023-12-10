require "../../_data/zr_db"

require "../../_util/char_util"
require "../../_util/viet_util"
require "../../_util/time_util"

require "./mt_term"
require "./zv_util"

class MT::ZvTerm
  class_getter db : ::DB::Database = ZR_DB

  ###

  include Crorm::Model
  schema "zvterm", :postgres

  field d_id : Int32 = 0, pkey: true
  field ipos : Int16 = 0, pkey: true
  field zstr : String, pkey: true

  field cpos : String = "X"

  field vstr : String = ""
  field attr : String = ""

  field toks : Array(Int32) = [] of Int32
  field ners : Array(String) = [] of String

  field segr : Int16 = 2_i16
  field posr : Int16 = 2_i16

  field uname : String = ""
  field mtime : Int32 = 0
  field plock : Int16 = 1_i16

  def self.new(cols : Array(String), d_id = 0)
    zstr, cpos, vstr = cols

    zstr = CharUtil.to_canon(zstr, true)
    vstr = vstr.empty? ? "" : VietUtil.fix_tones(vstr)

    new(zstr: zstr, d_id: d_id, cpos: cpos, vstr: vstr, attr: cols[3]? || "")
  end

  def self.new(zstr : String, cpos : String, vstr : String, attr : MtAttr, d_id : Int32 = 0)
    zstr = CharUtil.to_canon(zstr, true)
    vstr = VietUtil.fix_tones(vstr)
    new(zstr: zstr, d_id: d_id, cpos: cpos, vstr: vstr, attr: attr.to_str)
  end

  def initialize(@d_id, @zstr, @cpos,
                 @vstr = "", @attr = "",
                 @toks = [zstr.size], @ners = [] of String,
                 @segr = 2_i16, @posr = 2_i16,
                 @uname = "", @mtime = 0,
                 @plock = 1_i16)
    @ipos = MtEpos.parse(cpos).to_i16
  end

  def cpos=(cpos : MtEpos)
    @cpos = cpos.to_s
    @ipos = cpos.to_i16
  end

  def cpos=(@cpos : String)
    @ipos = MtEpos.parse(cpos).to_i16
  end

  def attr=(attr : MtAttr)
    @attr = attr.to_str
  end

  def to_json(jb : JSON::Builder)
    jb.object do
      jb.field "d_id", @d_id
      jb.field "zstr", @zstr
      jb.field "cpos", @cpos

      jb.field "vstr", @vstr
      jb.field "attr", @attr

      jb.field "toks", @toks
      jb.field "ners", @ners

      jb.field "segr", @segr
      jb.field "posr", @posr

      jb.field "uname", @uname
      jb.field "mtime", TimeUtil.cv_utime(@mtime)
      jb.field "plock", @plock
    end
  end

  ###

  def self.find(d_id : Int32, cpos : String, zstr : String)
    ipos = MtEpos.parse(cpos).value.to_i16
    self.find(d_id, ipos: ipos, zstr: zstr)
  end

  @@find_one_sql : String = @@schema.select_by_pkey + " limit 1"

  @[AlwaysInline]
  def self.find(d_id : Int32, ipos : Int16, zstr : String)
    @@db.query_one?(@@find_one_sql, d_id, ipos, zstr, as: self)
  end

  def self.delete(d_id : Int32, cpos : String, zstr : String)
    ipos = MtEpos.parse(cpos).value.to_i16
    self.delete(d_id, zstr, ipos: ipos)
  end

  DELETE_SQL = "delete from #{@@schema.table} where d_id = $1 and ipos = $3 and zstr = $2"

  @[AlwaysInline]
  def self.delete(d_id : Int32, ipos : Int16, zstr : String)
    @@db.exec DELETE_SQL, d_id, ipos, zstr
  end
end

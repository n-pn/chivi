# require "../../_data/zr_db"
# require "./shared/*"

# class MT::WsData
#   class_getter db : ::DB::Database = ZR_DB

#   ###

#   include Crorm::Model
#   schema "zvterm", :postgres

#   field d_id : Int32, pkey: true
#   field ipos : MtEpos, pkey: true, converter: MT::MtEpos
#   field zstr : String, pkey: true

#   field cpos : String = "X"
#   field fixp : String = "X"

#   field vstr : String = ""
#   field attr : String = ""

#   field toks : Array(Int32) = [] of Int32
#   field ners : Array(String) = [] of String

#   field segr : Int16 = 2_i16
#   field posr : Int16 = 2_i16

#   field plock : Int16 = 0_i16
#   field uname : String = ""
#   field mtime : Int32 = -1

#   def self.new(d_id : Int32, cols : Array(String), fixed : Bool = false)
#     zstr, cpos, vstr = cols

#     unless fixed
#       zstr = CharUtil.to_canon(zstr, true)
#       vstr = vstr.empty? ? "" : VietUtil.fix_tones(vstr)
#     end

#     new(
#       d_id: d_id,
#       cpos: cpos,
#       zstr: zstr,
#       vstr: vstr,
#       attr: cols[3]? || "",
#       fixed: true
#     )
#   end

#   def self.new(d_id : Int32, cpos : String, zstr : String,
#                vstr : String, attr : MtAttr, fixed : Bool = false)
#     unless fixed
#       zstr = CharUtil.to_canon(zstr, true)
#       vstr = vstr.empty? ? "" : VietUtil.fix_tones(vstr)
#     end

#     new(
#       d_id: d_id,
#       cpos: cpos,
#       zstr: zstr,
#       vstr: vstr,
#       attr: attr
#     )
#   end

#   def initialize(@d_id, @cpos, @zstr, @vstr = zstr,
#                  @ipos = MtEpos.parse(cpos),
#                  @attr = "", @toks = [zstr.size],
#                  @plock = 0_i16)
#   end

#   def add_track(@uname, @mtime = TimeUtil.cv_mtime)
#   end

#   def to_mt(dtype : DictType = :generic)
#     MtDefn.new(
#       vstr: vstr,
#       attr: MtAttr.parse_list(@attr),
#       dnum: DictEnum.from(dtype, @plock),
#       prio: MtDefn.calc_prio(@zstr.size)
#     )
#   end

#   def cpos=(@ipos : MtEpos)
#     @cpos = ipos.to_s
#   end

#   def cpos=(@cpos : String)
#     @ipos = MtEpos.parse(cpos)
#   end

#   def attr=(attr : MtAttr)
#     @attr = attr.to_str
#   end

#   def to_json(jb : JSON::Builder)
#     jb.object do
#       jb.field "d_id", @d_id
#       jb.field "zstr", @zstr
#       jb.field "cpos", @cpos

#       jb.field "vstr", @vstr
#       jb.field "attr", @attr

#       jb.field "toks", @toks
#       jb.field "ners", @ners

#       jb.field "segr", @segr
#       jb.field "posr", @posr

#       jb.field "uname", @uname
#       jb.field "mtime", TimeUtil.cv_utime(@mtime)
#       jb.field "plock", @plock
#     end
#   end

#   def as_temp
#     self.dup.tap { |x| x.dnum += 2_i8 }
#   end

#   ###

#   def self.init(d_id : Int32, cpos : String, zstr : String)
#     self.find(d_id: d_id, ipos: MtEpos.parse(cpos), zstr: zstr) || self.new(d_id: d_id, cpos: cpos, zstr: zstr)
#   end

#   def self.find(d_id : Int32, cpos : String, zstr : String)
#     self.find(d_id, ipos: MtEpos.parse(cpos), zstr: zstr)
#   end

#   @@find_one_sql : String = @@schema.select_by_pkey + " limit 1"

#   @[AlwaysInline]
#   def self.find(d_id : Int32, ipos : MtEpos, zstr : String)
#     @@db.query_one?(@@find_one_sql, d_id, ipos.value.to_i16, zstr, as: self)
#   end

#   def self.delete(d_id : Int32, cpos : String, zstr : String)
#     self.delete(d_id, zstr, ipos: MtEpos.parse(cpos))
#   end

#   DELETE_SQL = <<-SQL
#     delete from #{@@schema.table}
#     where d_id = $1 and ipos = $2 and zstr = $3
#     SQL

#   @[AlwaysInline]
#   def self.delete(d_id : Int32, ipos : MtEpos, zstr : String)
#     @@db.exec DELETE_SQL, d_id, ipos.value.to_i16, zstr
#   end
# end

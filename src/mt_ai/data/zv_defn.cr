require "../../_data/zr_db"
require "../base/*"

class MT::ZvDefn
  class_getter init_sql = <<-SQL
    CREATE TABLE IF NOT EXISTS zv_defn(
      d_id int NOT NULL,
      cpos text NOT NULL,
      zstr text NOT NULL,
      --
      vstr text NOT NULL DEFAULT '',
      attr text NOT NULL DEFAULT '',
      rank int not null default 0,
      --
      flags int NOT NULL DEFAULT 1,
      mtime int NOT NULL DEFAULT 0,
      uname text NOT NULL DEFAULT '',
      --
      PRIMARY KEY (d_id, cpos, zstr)
    ) strict, without rowid;
    SQL

  DIR = ENV["MT_DIR"]? || "var/mt_db"

  class_getter db_path = "#{DIR}/zv_defn.db3"

  ###

  include Crorm::Model
  schema "zv_defn", :sqlite, strict: false

  field d_id : Int32, pkey: true
  field cpos : String, pkey: true
  field zstr : String, pkey: true

  field vstr : String = ""
  field attr : String = ""
  field rank : Int32 = 0

  field flags : Int32 = 1
  field mtime : Int32 = 0
  field uname : String = ""

  # def initialize(@d_id : Int32, @cpos : String, @zstr : String,
  #                @vstr : String, attr : MtAttr, @rank = 0,
  #                @flags = 2, @mtime = 0, @uname = "",
  #                fixed : Bool = true)
  #   @attr = attr.to_str
  #   return if fixed

  #   @zstr = CharUtil.to_canon(zstr, true)
  #   @vstr = vstr.empty? ? "" : VietUtil.fix_tones(vstr)
  # end

  def initialize(@d_id, @cpos, @zstr,
                 @vstr = "", @attr = "", @rank = 0,
                 @flags = 1, @mtime = 0, @uname = "")
  end

  def add_track(@uname, @mtime = TimeUtil.cv_mtime)
  end

  def cpos=(epos : MtEpos)
    @cpos = epos.to_s
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
      jb.field "rank", @rank

      jb.field "flags", @flags
      jb.field "uname", @uname
      jb.field "mtime", TimeUtil.cv_utime(@mtime)
    end
  end

  def as_temp
    self.dup.tap { |x| x.dnum += 2_i8 }
  end

  ###

  def self.init(d_id : Int32, cpos : String, zstr : String)
    self.find(d_id: d_id, epos: MtEpos.parse(cpos), zstr: zstr) || self.new(d_id: d_id, cpos: cpos, zstr: zstr)
  end

  def self.find(d_id : Int32, cpos : String, zstr : String)
    self.find(d_id, epos: MtEpos.parse(cpos), zstr: zstr)
  end

  @@find_one_sql : String = @@schema.select_by_pkey + " limit 1"

  @[AlwaysInline]
  def self.find(d_id : Int32, epos : MtEpos, zstr : String)
    @@db.query_one?(@@find_one_sql, d_id, epos.value.to_i16, zstr, as: self)
  end

  def self.delete(d_id : Int32, cpos : String, zstr : String)
    self.delete(d_id, zstr, epos: MtEpos.parse(cpos))
  end

  DELETE_SQL = <<-SQL
    delete from #{@@schema.table}
    where d_id = $1 and epos = $2 and zstr = $3
    SQL

  @[AlwaysInline]
  def self.delete(d_id : Int32, epos : MtEpos, zstr : String)
    @@db.exec DELETE_SQL, d_id, epos.value.to_i16, zstr
  end
end

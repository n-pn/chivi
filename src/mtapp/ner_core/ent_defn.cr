require "crorm"
require "crorm/sqlite3"

class MT::EntDefn
  include Crorm::Model
  @@table = "defns"

  @[AlwaysInline]
  def self.db_path(dname : String | Int32)
    "var/mtdic/fixed/zents/#{dname}.dic"
  end

  def self.init_sql
    {{read_file("#{__DIR__}/ent_defn.sql")}}
  end

  ###

  field id : Int32, primary: true

  field dic : Int32 = 0
  field tab : Int32 = 0

  field key : String = ""
  field val : String = ""

  field ptag : String = ""
  field prio : Int32 = 2

  field uname : String = ""
  field mtime : Int64 = 0

  field _ctx : String = ""

  field _prev : Int32 = 0
  field _flag : Int32 = 1

  SPLIT = 'ǀ'

  def to_json(jb : JSON::Builder)
    jb.object do
      jb.field "id", self.id

      jb.field "dic", self.dic
      jb.field "tab", self.tab

      jb.field "key", self.key
      jb.field "val", self.val.gsub('ǀ', " | ")

      jb.field "ptag", self.ptag
      jb.field "prio", self.prio

      jb.field "uname", self.uname
      jb.field "mtime", self.utime

      jb.field "state", tab < 0 ? "Xoá" : (_prev > 0 ? "Sửa" : "Thêm")
    end
  end

  def dic=(dname : String)
    @dic = DbDict.get_id(dname)
  end

  def val=(vals : Array(String))
    @val = vals.join(SPLIT)
  end

  def ptag=(tags : Array(String))
    @ptag = tags.join(' ')
  end

  def mtime=(time : Time)
    @mtime = self.class.mtime(time)
  end

  def utime
    self.mtime > 0 ? EPOCH &+ self.mtime &* 60 : 0
  end

  EPOCH = Time.utc(2020, 1, 1, 0, 0, 0).to_unix

  def self.mtime(rtime : Time = Time.utc)
    (rtime.to_unix - EPOCH) // 60
  end
end

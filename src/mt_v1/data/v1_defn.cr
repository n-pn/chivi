require "crorm/model"
require "sqlite3"

require "./v1_dict"

class M1::DbDefn
  class_getter db_path = "var/mtapp/v1dic/v1_defns.dic"

  class_getter init_sql = <<-SQL
    CREATE TABLE IF NOT EXISTS defns (
      "id" integer PRIMARY KEY,
      --
      "dic" integer NOT NULL DEFAULT 0,
      "tab" integer NOT NULL DEFAULT 0,
      --
      "key" varchar NOT NULL, -- raw input
      "val" varchar NOT NULL, -- raw value
      --
      "ptag" varchar NOT NULL DEFAULT '', -- generic postag label
      "prio" integer NOT NULL DEFAULT 2, -- priority rank for word segmentation
      --
      "uname" varchar NOT NULL DEFAULT '', -- user name
      "mtime" integer NOT NULL DEFAULT 0, -- term update time
      --
      '_ctx' varchar NOT NULL DEFAULT ''
      --
      "_prev" integer NOT NULL DEFAULT 0,
      "_flag" integer NOT NULL DEFAULT 0 -- marking term as active or inactive
    );

    CREATE INDEX IF NOT EXISTS terms_word_idx ON defns (key);
    CREATE INDEX IF NOT EXISTS defns_scan_idx ON defns (dic);
    CREATE INDEX IF NOT EXISTS defns_ptag_idx ON defns (ptag);
    CREATE INDEX IF NOT EXISTS defns_user_idx ON defns (uname);
    SQL

  ###

  include Crorm::Model
  schema "defns"

  ###

  field id : Int32, pkey: true, auto: true

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

  def initialize
  end

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

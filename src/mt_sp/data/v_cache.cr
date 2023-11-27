require "crorm"
require "../../_util/hash_util"

class SP::VCache
  VC_DIR = ENV.fetch("VC_DIR", "var/cache/vdata")
  Dir.mkdir_p(VC_DIR)

  class_getter init_sql : String = <<-SQL

  create table vcache(
    fnv int not null,
    obj text not null default '',
    val text not null default '',

    mtime int not null default 0,
    noted text not null default '',

    primary key (fnv, obj, val)
  ) strict, without rowid;
  SQL

  DB_CACHE = {} of Char => Crorm::SQ3

  def self.load_db(char : Char)
    DB_CACHE[char] ||= self.db(char)
  end

  def self.db_path(word : String)
    "#{DIR}/#{word[0]}-vcache.db3"
  end

  def self.db_path(char : Char)
    "#{DIR}/#{char}-vcache.db3"
  end

  ###

  include Crorm::Model
  schema "vcache", :sqlite, multi: true

  field fnv : Int64, pkey: true  # fnv_1a checksum of input string
  field obj : String, pkey: true # type of row
  field val : String, pkey: true # value of row

  field mtime : Int64 = 0   # last modified by
  field noted : String = "" # additional info for tracking purpose

  def initialize(@fnv, @obj, @val = "", @mtime = Time.utc.to_unix, @noted = "")
  end

  ###

  def self.gen_fnv(raw : String)
    HashUtil.fnv_1a_64(raw).unsafe_as(Int64)
  end

  def self.get_all(raw : String)
    self.load_db(raw[0]).open_ro do |db|
      db.query_all("select * from vcache where fnv = $1", gen_fnv(raw), as: self)
    end
  end

  def self.get_obj(raw : String, obj : String)
    self.load_db(raw[0]).open_ro do |db|
      db.query_all("select * from vcache where fnv = $1 and obj = $2", gen_fnv(raw), obj, as: self)
    end
  end

  def self.upsert!(raw : String, obj : String, val : String, mtime = Time.utc.to_unix, noted = "")
    fnv = gen_fnv(raw)

    self.load_db(raw[0]).open_tx do |db|
      new(fnv, "zh", raw, mtime: 0, noted: 0).upsert!(db: db)
      new(fnv, obj, val, mtime: mtime, noted: noted).upsert!(db: db)
    end
  end
end

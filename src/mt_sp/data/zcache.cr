require "crorm"
require "../../_util/hash_util"

class SP::Zcache
  QT_DIR = ENV.fetch("QT_DIR", "var/mtdic/cache")
  Dir.mkdir_p(QT_DIR)

  class_getter init_sql : String = <<-SQL

  create table zcache(
    fnv int not null,
    obj text not null default '',
    val text not null default '',

    mtime int not null default 0,
    noted text not null default '',

    primary key (fnv, obj, val)
  ) strict, without rowid;
  SQL

  # puts db_path('東')
  # puts db_path('京')

  DB_CACHE = {} of Int32 => Crorm::SQ3

  def self.load_db(char : Char)
    cmod = char.ord % (2 ** 16)
    DB_CACHE[cmod] ||= self.db(cmod.to_s(base: 16))
  end

  # def self.db_path(char : Char)
  #   db_path(cmod.to_s(base: 16))
  # end

  def self.db_path(suff : String)
    "#{DIR}/words-#{suff}.db3"
  end

  ###

  include Crorm::Model
  schema "zcache", :sqlite, multi: true

  field fnv : Int64, pkey: true  # fnv_1a checksum of input string
  field obj : String, pkey: true # type of row
  field val : String, pkey: true # value of row

  field mtime : Int64 = 0   # last modified by
  field noted : String = "" # additional info for tracking purpose

  def initialize(@fnv, @obj, @val = "", @mtime = Time.utc.to_unix, @noted = "")
  end

  ###

  def self.get_all(raw : String)
    self.load_db(raw[0]).open_ro do |db|
      fnv = HashUtil.fnv_1a_64(raw).unsafe_as(Int64)
      db.query_all("select * from zcache where fnv = $1", fnv, as: self)
    end
  end

  def self.get_obj(raw : String, obj : String)
    self.load_db(raw[0]).open_ro do |db|
      fnv = HashUtil.fnv_1a_64(raw).unsafe_as(Int64)
      db.query_all("select * from zcache where fnv = $1 and obj = $2", fnv, obj, as: self)
    end
  end

  def self.upsert!(raw : String, obj : String, val : String, mtime = Time.utc.to_unix, noted = "")
    self.load_db(raw[0]).open_rw do |db|
      fnv = HashUtil.fnv_1a_64(raw).unsafe_as(Int64)
      new(fnv, obj, val, mtime: mtime, noted: noted).upsert!(db: db)
    end
  end
end

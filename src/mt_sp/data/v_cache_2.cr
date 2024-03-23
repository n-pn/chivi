require "../../_data/zr_db"
require "../../_util/hash_util"
require "../../_util/time_util"

struct SP::VCache2
  ###

  class_getter init_sql : String = <<-SQL
    CREATE TABLE IF NOT EXISTS vcache (
      zkey int not null primary key,
      vstr text not null,
      _mtz int not null default 0
    ) strict, without rowid;
  SQL

  DIR = "var/cache/vdata"
  Dir.mkdir_p(DIR)

  def self.db_path(type : String)
    "#{DIR}/#{type}.db3"
  end

  include Crorm::Model
  schema "vcache", :sqlite, multi: true

  field zkey : Int64, pkey: true # fnv_1a checksum of input string
  field vstr : String            # cache value
  field _mtz : Int32 = 0         # last modified at

  def initialize(@zkey, @vstr = "", @_mtz = TimeUtil.cv_mtime)
  end

  ###

  @[AlwaysInline]
  def self.gen_zkey(zstr : String)
    HashUtil.fnv_1a_64(zstr).unsafe_as(Int64)
  end

  GET_VSTR_SQL = "select vstr from vcache where zkey = $1 and _mtz >= $2 limit 1"

  def self.get_vstr(type : String, zstr : String, _mtz = 0) : String?
    self.db(type).query_one?(GET_VSTR_SQL, self.gen_zkey(zstr), _mtz, as: String)
  end

  def self.get_all(type : String, zstrs : Array(String), _mtz = TimeUtil.cv_fresh(2.weeks))
    cached = [] of String
    z_idxs = [] of Int32
    z_keys = [] of Int32

    self.db(type).open_ro do |db|
      zstrs.each_with_index do |zstr, zidx|
        zkey = self.gen_zkey(zstr)

        if vstr = db.query_one?(GET_VSTR_SQL, zkey, _mtz, as: String)
          cached << vstr
        else
          cached << ""
          z_idxs << zidx
          z_keys << zkey
        end
      end
    end

    {cached, z_idxs, z_keys}
  end

  def self.upsert!(type : String, zkeys : Array(Int64), vstrs : Array(String), _mtz = TimeUtil.cv_mtime)
    sef.db(type).open_tx do |db|
      zkeys.zip(vstrs) do |zkey, vstr|
        new(zkey, vstr: vstr, _mtz: _mtz).upsert!(db: db)
      end
    end
  end

  def self.upsert!(type : String, zkey : Int64, vstr : String, _mtz = TimeUtil.cv_mtime)
    self.db(type).open_rw { |db| new(zkey, vstr: vstr, _mtz: _mtz).upsert!(db: db) }
  end
end

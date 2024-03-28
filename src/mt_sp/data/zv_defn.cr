require "../../_util/char_util"
require "../../_util/viet_util"

require "../../_data/_data"

class SP::Zvdefn
  class_getter db : ::DB::Database = PGDB

  ###

  include Crorm::Model
  schema "zvdefns", :postgres, strict: false

  field id : Int32, auto: true

  field dict : String, pkey: true
  field zstr : String, pkey: true
  field cpos : String, pkey: true

  field vstr : String = ""
  field attr : String = ""
  field rank : Int16 = 0_i16

  field _user : String = ""
  field _time : Int32 = -1
  field _lock : Int16 = 0_i16

  def initialize(@dict : String, @cpos : String, @zstr : String,
                 @vstr : String = "", @attr : String = "", @rank : Int16 = 1,
                 @_user : String = "", @_time = -1, @_lock : Int16 = 0)
  end

  def add_defn(vstr : String, attr : String, rank : Int16)
    vstr = vstr.gsub(/\p{C}+/, ' ').strip
    @vstr = vstr.empty? ? vstr : VietUtil.fix_tones(vstr.unicode_normalize(:nfkc))

    @attr = attr.strip
    @rank = rank < 0 ? 0_i16 : rank
  end

  def add_meta(@_user = "", @_time = TimeUtil.cv_mtime, _lock = 0_i16)
    @_lock = _lock >= 0 && @vstr.empty? ? -_lock : _lock
  end

  def to_json(jb : JSON::Builder)
    jb.object do
      jb.field "dict", @dict
      jb.field "zstr", @zstr
      jb.field "cpos", @cpos

      jb.field "vstr", @vstr
      jb.field "attr", @attr
      jb.field "rank", @rank

      jb.field "user", @_user
      jb.field "time", TimeUtil.cv_utime(@_time)
      jb.field "lock", @_lock
    end
  end

  ###

  def self.init(dict : String, zstr : String, cpos : String)
    self.find(dict: dict, zstr: zstr, cpos: cpos) || self.new(dict: dict, zstr: zstr, cpos: cpos)
  end

  @@find_one_sql : String = @@schema.select_by_pkey + " limit 1"

  @[AlwaysInline]
  def self.find(dict : String, zstr : String, cpos : String)
    @@db.query_one?(@@find_one_sql, dict, zstr, cpos, as: self)
  end

  @[AlwaysInline]
  def self.delete(dict : String, zstr : String, cpos : String)
    @@db.exec "delete from zvdefns where dict = $1 and zstr = $2 and cpos = $3", dict, zstr, cpos
  end

  @[AlwaysInline]
  def self.delete_all(dict : Int32, zstr : String)
    @@db.exec "delete from zvdefns where dict = $1 and zstr = $2", dict, zstr
  end
end

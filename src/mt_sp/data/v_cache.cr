require "../../_data/zr_db"
require "../../_util/hash_util"
require "../../_util/time_util"

class SP::VCache
  enum Obj : Int16
    Ztext = 0 # original text
    Py_tm = 1 # pinyin with tone marks
    Hviet = 5 # hanviet

    Vi_lv = 10 # translation from lacviet
    Vi_vp = 11 # translation from vietphrase dicts

    Vi_qt = 15 # translated by old translator
    Vi_mt = 16 # translated by new translator

    Vi_uc = 20 # chivi user submitted content

    Ms_zv = 30 # translated by bing from zh to vi
    Gg_zv = 31 # translated by google from zh to vi
    Bd_zv = 32 # translated by baidu from zh to vi
    C_gpt = 33 # translated by custom gpt model

    Ms_ze = 50 # translated by bing from zh to en
    Gg_ze = 51 # translated by google from zh to en
    Bd_ze = 52 # translated by baidu from zh to en
    Dl_ze = 53 # translated by deepl from zh to en

    def self.for_bd(tl : String = "vie")
      tl == "vie" ? Bd_zv : Bd_ze
    end
  end

  ###

  class_getter db : DB::Database = ZR_DB

  include Crorm::Model
  schema "vcache", :postgres, strict: false

  field rid : Int64, pkey: true # fnv_1a checksum of input string
  field obj : Int16, pkey: true # type of row
  field vid : Int32, pkey: true # hash of val

  field val : String    # value of row
  field mcv : Int32 = 0 # last modified by

  def self.new(rid : Int64, obj : Obj, val = "", mcv = TimeUtil.cv_mtime)
    new(rid, obj: obj.value, val: val, mcv: mcv)
  end

  def initialize(@rid, @obj, @val = "", @mcv = TimeUtil.cv_mtime)
    @vid = HashUtil.fnv_1a(val).unsafe_as(Int32)
  end

  ###

  def self.gen_rid(raw : String)
    HashUtil.fnv_1a_64(raw).unsafe_as(Int64)
  end

  def self.get_all(raw : String)
    @@db.query_all("select * from vcache where rid = $1", gen_rid(raw), as: self)
  end

  def self.get_obj(raw : String, obj : String)
    self.get_obj(raw, Obj.parse(obj))
  end

  def self.get_obj(raw : String, obj : Obj)
    @@db.query_all("select * from vcache where rid = $1 and obj = $2", gen_rid(raw), obj.value, as: self)
  end

  def self.get_val(obj : Obj, raws : Array(String), mcv = TimeUtil.cv_fresh(2.weeks))
    query = "select rid, val from vcache where obj = $1 and rid = any ($2)"

    rids = raws.map { |raw| gen_rid(raw) }
    hash = @@db.query_all(query, obj.value, rids, as: {Int64, String}).to_h

    output = [] of String
    blanks = [] of Int32

    rids.each_with_index do |rid, idx|
      if val = hash[rid]?
        output << val
      else
        output << "<!>"
        blanks << idx
      end
    end

    {output, blanks}
  end

  def self.upsert!(raw : String, obj : String, val : String, mcv = TimeUtil.cv_mtime)
    self.upsert!(raw, Obj.parse(obj))
  end

  def self.upsert!(raw : String, obj : Obj, val : String, mcv = TimeUtil.cv_mtime)
    rid = gen_rid(raw)

    @@db.transaction do |db|
      new(rid, obj: :ztext, val: raw, mcv: 0).upsert!(db: db)
      new(rid, obj: obj, val: val, mcv: mcv).upsert!(db: db)
    end
  end

  def self.cache!(obj : Obj, raws : Array(String), vals : Array(String), mcv = TimeUtil.cv_mtime)
    items = [] of self

    vals.zip(raws).each do |val, raw|
      rid = gen_rid(raw)
      items << new(rid, obj: :ztext, val: raw, mcv: 0)
      items << new(rid, obj: obj, val: val, mcv: mcv)
    end

    @@db.transaction do |tx|
      items.each(&.upsert!(db: tx.connection))
    end
  end
end

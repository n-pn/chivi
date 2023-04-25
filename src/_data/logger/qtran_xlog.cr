require "crorm"
require "../_data"
require "../../_util/hash_util"

class CV::QtranXlog
  include Crorm::Model

  @@db : DB::Database = PGDB
  @@table = "qtran_xlogs"

  field id : Int32 = 0, primary: true
  field viuser_id : Int32 = 0

  field input_hash : Int32 = 0
  field char_count : Int32 = 0
  field point_cost : Int32 = 0

  field wn_dic : Int32 = 0
  field w_udic : Bool = true

  field mt_ver : Int16 = 1_i16

  field cv_ner : Bool = false
  field ts_sdk : Bool = false
  field ts_acc : Bool = false

  field created_at : Time = Time.utc

  def initialize(
    @input_hash,
    @char_count,
    @viuser_id,
    @wn_dic = 0,
    @w_udic = true,
    @mt_ver = 1_16,
    @cv_ner = false,
    @ts_sdk = false,
    @ts_acc = false
  )
    point_cost = calculate_cost(char_count, w_udic, mt_ver, cv_ner, ts_sdk, ts_acc)
    prev_count = self.class.count(viuser_id, input_hash)
    @point_cost = prev_count < 1 ? point_cost : point_cost // (prev_count &+ 1)
  end

  MT_VER_MUL = {0.5, 1, 1.5}

  W_UDIC_MUL = 1
  CV_NER_MUL = 1
  TS_SDK_MUL = 2
  TS_ACC_MUL = 3

  def calculate_cost(c_len : Int32, w_udic = true, mt_ver = 1, cv_ner = false, ts_sdk = false, ts_acc = false)
    cost = (c_len * MT_VER_MUL[mt_ver]).round.to_i

    cost &+= c_len &* W_UDIC_MUL if w_udic
    cost &+= c_len &* CV_NER_MUL if cv_ner
    cost &+= c_len &* TS_SDK_MUL if ts_sdk
    cost &+= c_len &* TS_ACC_MUL if ts_acc

    cost
  end

  def create!(db = @@db)
    stmt = <<-SQL
      insert into #{@@table} (
        viuser_id, input_hash,
        char_count, point_cost,
        wn_dic, w_udic,
        mt_ver, cv_ner,
        ts_sdk, ts_acc,
        created_at
      ) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
    SQL

    db.exec stmt, @viuser_id, @input_hash, @char_count, @point_cost,
      @wn_dic, @w_udic, @mt_ver, @cv_ner, @ts_sdk, @ts_acc, @created_at
  end

  ####

  def self.count(vu_id : Int32, ihash : Int32)
    @@db.query_one <<-SQL, vu_id, ihash, as: Int32
      select COALESCE(COUNT(*), 0)::int from "#{@@table}"
      where viuser_id = $1 and input_hash = $2
    SQL
  end

  def self.count(vu_id : Nil, ihash : Int32)
    @@db.query_one <<-SQL, ihash, as: Int32
      select COALESCE(COUNT(*), 0)::int from "#{@@table}"
      where input_hash = $1
    SQL
  end

  def self.count(vu_id : Int32, ihash : Nil)
    @@db.query_one <<-SQL, vu_id, as: Int32
      select COALESCE(COUNT(*), 0)::int from "#{@@table}"
      where viuser_id = $1
    SQL
  end

  def self.count(vu_id : Nil, ihash : Nil)
    @@db.query_one <<-SQL, as: Int32
      select COALESCE(COUNT(*), 0)::int from "#{@@table}"
    SQL
  end

  record UserStat, viuser_id : Int32, point_cost : Int64 do
    include DB::Serializable
    include JSON::Serializable
  end

  def self.user_stats(from_time = Time.local - 7.days, upto_time = Time.local + 1.days)
    @@db.query_all <<-SQL, from_time.to_s("%F"), upto_time.to_s("%F"), as: UserStat
      select viuser_id, sum(point_cost) as point_cost from "#{@@table}"
      where created_at >= $1 and created_at <= $2
      group by viuser_id
      order by point_cost desc
    SQL
  end

  record BookStat, wninfo_id : Int32, point_cost : Int64 do
    include DB::Serializable
    include JSON::Serializable
  end

  def self.book_stats(from_time = Time.local - 7.days, upto_time = Time.local + 1.days)
    @@db.query_all <<-SQL, from_time.to_s("%F"), upto_time.to_s("%F"), as: BookStat
      select wn_dic as wninfo_id, sum(point_cost) as point_cost from "#{@@table}"
      where created_at >= $1 and created_at <= $2
      group by wn_dic
      order by point_cost desc
    SQL
  end

  def self.fetch(vu_id : Int32, ihash : Nil, limit = 50, offset = 0)
    @@db.query_all <<-SQL, vu_id, limit, offset, as: QtranXlog
      select * from "#{@@table}"
      where viuser_id = $1
      order by id desc
      limit $2 offset $3
    SQL
  end

  def self.fetch(vu_id : Nil, ihash : Nil, limit = 50, offset = 0)
    @@db.query_all <<-SQL, limit, offset, as: QtranXlog
      select * from "#{@@table}"
      order by id desc
      limit $1 offset $2
    SQL
  end

  def self.fetch(vu_id : Int32, ihash : Int32, limit = 50, offset = 0)
    @@db.query_all <<-SQL, vu_id, ihash, limit, offset, as: QtranXlog
      select * from "#{@@table}"
      where viuser_id = $1 and input_hash = $2
      order by id desc
      limit $3 offset $4
    SQL
  end

  def self.fetch(vu_id : Nil, ihash : Int32, limit = 50, offset = 0)
    @@db.query_all <<-SQL, ihash, limit, offset, as: QtranXlog
      select * from "#{@@table}"
      where input_hash = $1
      order by id desc
      limit $2 offset $3
    SQL
  end

  def self.today_point_cost(viuser_id : Int32)
    stmt = "select sum(point_cost) from #{@@table} where viuser_id = $1 and created_at >= $2"
    @@db.query_one(stmt, viuser_id, Time.local.to_s("%F"), as: Int64) rescue 0
  end
end

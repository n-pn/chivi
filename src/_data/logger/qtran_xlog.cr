require "crorm"
require "../_data"
require "../../_util/hash_util"

class CV::QtranXlog
  include Crorm::Model
  @@table = "qtran_xlogs"

  field id : Int32, primary: true
  field viuser_id : Int32

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
    input : String,
    @viuser_id,
    @wn_dic = 0,
    @w_udic = true,
    @mt_ver = 1_16,
    @cv_ner = false,
    @ts_sdk = false,
    @ts_acc = false
  )
    @char_count = isize = input.size
    @input_hash = ihash = HashUtil.fnv_1a(input).unsafe_as(Int32)

    point_cost = calculate_cost(isize, w_udic, mt_ver, cv_ner, ts_sdk, ts_acc)
    prev_count = self.class.count_previous(viuser_id, ihash)

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

  def self.count_previous(viuser_id : Int32, input_hash : Int32) : Int32
    stmt = "select count(*)::int from #{@@table} where viuser_id = $1 and input_hash = $2"
    PGDB.query_one(stmt, viuser_id, input_hash, as: Int32) rescue 0
  end

  def create!(db = PGDB)
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
end

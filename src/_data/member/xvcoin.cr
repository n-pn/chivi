require "../_data"
require "../member/unotif"

class CV::Xvcoin
  enum Kind : Int32
    Normal = 10

    PriviUg = 20
    QtranDl = 30

    Reward = 50
    Donate = 60
  end

  class_getter db : DB::Database = PGDB

  include Crorm::Model
  schema "vcoin_xlogs", :postgres, strict: false

  field id : Int32, pkey: true, auto: true
  field kind : Int32 = 0

  # kind values
  # 0: normal transaction between user
  # 10: spent by upgrade privi
  # 20: spent by download translation
  # 100: reward by system for donating

  field sender_id : Int32 = 0

  field target_id : Int32 = 0
  field target_name : String = ""

  field amount : Int32 = 0
  field reason : String = ""

  timestamps

  def initialize(kind : Kind, @sender_id, @target_id, @amount, @reason = "", @target_name = "")
    @kind = kind.value
  end

  def initialize(@kind, @sender_id, @target_id, @amount, @reason = "", @target_name = "")
  end

  ####

  def to_json(jb : JSON::Builder)
    jb.object do
      jb.field "id", self.id
      jb.field "sender_id", self.sender_id
      jb.field "target_id", self.target_id

      jb.field "amount", self.amount
      jb.field "reason", self.reason

      jb.field "ctime", self.created_at.to_unix
    end
  end

  def self.build_select_sql(vu_id : Int32)
    @@schema.select_stmt do |sql|
      sql << " where (sender_id = $3 or target_id = $3)"
      sql << " order by id desc limit $1 offset $2"
    end
  end

  def self.build_select_sql(vu_id : Nil)
    @@schema.select_stmt do |sql|
      sql << " order by id desc limit $1 offset $2"
    end
  end

  ###

  # GET_VCOIN_SQL = "select vcoin from viusers where id = $1"

  SUBTRACT_VCOIN_SQL = <<-SQL
    update viusers set vcoin = vcoin - $1
    where id = $2 and vcoin >= $1
    returning vcoin
    SQL

  INCREASE_VCOIN_SQL = <<-SQL
    update viusers set vcoin = vcoin + $1
    where id = $2
    returning vcoin
    SQL

  def self.subtract(vu_id : Int32, value : Int32)
    # TODO: convert vcoin to vietnam dong
    @@db.query_one?(SUBTRACT_VCOIN_SQL, value, vu_id, as: Int32)
  end

  def self.increase(vu_id : Int32, value : Int32)
    # TODO: convert vcoin to vietnam dong
    @@db.query_one(INCREASE_VCOIN_SQL, value, vu_id, as: Int32)
  end
end

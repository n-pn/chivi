require "../_data"
require "../member/unotif"

class CV::Xvoin
  enum Kind : Int32
    Normal = 10

    PriviUg = 20
    QtranDl = 30

    Reward = 50
    Donate = 60

    Unlock = 100
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

  field amount : Float64 = 0_f64
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

      jb.field "amount", self.amount.round(2)
      jb.field "reason", self.reason

      jb.field "ctime", self.created_at.to_unix
    end
  end

  def self.build_select_sql
  end
end

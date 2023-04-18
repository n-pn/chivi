require "../_base"
require "../member/unotif"

class CV::VcoinXlog
  enum Kind : Int16
    Normal = 10

    PriviUg = 20
    QtranDl = 30

    Reward = 50
    Donate = 60
  end

  include Clear::Model
  self.table = "vcoin_xlogs"

  primary_key type: :serial
  column kind : Int16 = 0

  # kind values
  # 0: normal transaction between user
  # 10: spent by upgrade privi
  # 20: spent by download translation
  # 100: reward by system for donating

  column sender_id : Int32

  column target_id : Int32
  column target_name : String = ""

  column amount : Float64 = 0_f64
  column reason : String = ""

  timestamps

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
end

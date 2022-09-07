require "./_base"

class CV::ExchVcoin
  include Clear::Model

  self.table = "exch_vcoins"
  primary_key

  belongs_to sender : Viuser, foreign_key: "sender_id", foreign_key_type: Int32
  belongs_to receiver : Viuser, foreign_key: "receiver_id", foreign_key_type: Int32

  column amount : Int32 = 0
  column reason : String = ""
end

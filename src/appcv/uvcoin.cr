class CV::Uvcoin
  include Clear::Model

  self.table = "uvcoins"
  primary_key

  belongs_to sender : Cvuser, foreign_key: "sender_id"
  belongs_to receiver : Cvuser, foreign_key: "receiver_id"

  column amount : Int32 = 0
  column reason : String = ""
end

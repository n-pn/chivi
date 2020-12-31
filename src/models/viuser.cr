require "./_models"

# user infos

class CV::Models::Viuser
  include Clear::Model
  self.table = "viusers"

  primary_key type: :serial

  column email : String
  column uname : String
  column cpass : String

  column urole : String
  column dlock : Int32

  column vip_level : Int32
  column vip_bonus : Int32
  column vip_until : Time?

  timestamps
end

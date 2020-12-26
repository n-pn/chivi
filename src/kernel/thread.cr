require "./_models"
require "./viuser"
require "./nvinfo"

class Chivi::Thread
  include Clear::Model
  self.table = "threads"

  primary_key type: :serial

  belongs_to viuser : Viuser, foreign_key_type: Int32
  belongs_to nvinfo : Nvinfo, foreign_key_type: Int32

  timestamps
end

require "./_models"
require "./viuser"
require "./nvinfo"
require "./chseed"

class Chivi::Nvmark
  include Clear::Model
  self.table = "nvmarks"

  primary_key type: :serial

  belongs_to viuser : Viuser, foreign_key_type: Int32
  belongs_to nvinfo : Nvinfo, foreign_key_type: Int32
  belongs_to chseed : Chseed, foreign_key_type: Int32

  timestamps
end

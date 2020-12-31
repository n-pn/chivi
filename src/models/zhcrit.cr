require "./_models"
require "./zhuser"
require "./zhlist"
require "./nvlist"

class CV::Models::Zhcrit
  include Clear::Model
  self.table = "zhcrits"

  primary_key type: :serial

  belongs_to zhuser : Zhuser, foreign_key_type: Int32
  belongs_to zhlist : Zhlist, foreign_key_type: Int32
  belongs_to nvinfo : Nvinfo, foreign_key_type: Int32

  timestamps
end

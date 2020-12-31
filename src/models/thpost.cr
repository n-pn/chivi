require "./_models"
require "./member"
require "./nvinfo"
require "./thread"

class CV::Models::Remark
  include Clear::Model
  self.table = "remarks"

  primary_key type: :serial
  timestamps

  belongs_to member : Member, foreign_key_type: Int32
  belongs_to nvinfo : Nvinfo, foreign_key_type: Int32
  belongs_to thread : Thread, foreign_key_type: Int32
end

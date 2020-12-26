require "./_models"
require "./member"
require "./serial"
require "./thread"

class Chivi::Remark
  include Clear::Model
  self.table = "remarks"

  primary_key type: :serial
  timestamps

  belongs_to member : Member, foreign_key_type: Int32
  belongs_to serial : Serial, foreign_key_type: Int32
  belongs_to thread : Thread, foreign_key_type: Int32
end

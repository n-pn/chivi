require "./_models"
require "./member"
require "./serial"
require "./source"

class Chivi::Follow
  include Clear::Model
  self.table = "follows"

  primary_key type: :serial
  timestamps

  belongs_to member : Member, foreign_key_type: Int32
  belongs_to serial : Serial, foreign_key_type: Int32
  belongs_to source : Source, foreign_key_type: Int32
end

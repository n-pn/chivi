require "./_models"
require "./member"
require "./serial"

class Chivi::Thread
  include Clear::Model
  self.table = "threads"

  primary_key type: :serial
  timestamps

  belongs_to member : Member, foreign_key_type: Int32
  belongs_to member : Serial, foreign_key_type: Int32
end

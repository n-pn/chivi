require "./_models"
require "./member"

class Chivi::Critic
  include Clear::Model
  self.table = "critics"

  primary_key type: :serial
  timestamps

  belongs_to member : Member, foreign_key_type: Int32
end

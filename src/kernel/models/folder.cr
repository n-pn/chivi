require "./_models"
require "./member"
require "./critic"

class Chivi::Folder
  include Clear::Model
  self.table = "folders"

  primary_key type: :serial
  timestamps

  belongs_to member : Member, foreign_key_type: Int32
  belongs_to critic : Critic, foreign_key_type: Int32
end

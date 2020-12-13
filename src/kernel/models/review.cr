require "./_models"
require "./member"
require "./critic"
require "./folder"

class Chivi::Review
  include Clear::Model
  self.table = "reviews"

  primary_key type: :serial
  timestamps

  belongs_to member : Member, foreign_key_type: Int32
  belongs_to critic : Critic, foreign_key_type: Int32
  belongs_to folder : Folder, foreign_key_type: Int32
end

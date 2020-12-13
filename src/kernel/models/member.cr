require "./_models"

# user infos

class Chivi::Member
  include Clear::Model
  self.table = "members"

  primary_key type: :serial
  timestamps
end

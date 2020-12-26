require "./_models"

# user infos

class Chivi::Viuser
  include Clear::Model
  self.table = "viusers"

  primary_key type: :serial
  timestamps
end

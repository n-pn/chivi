require "./_models"

class Chivi::Zhuser
  include Clear::Model
  self.table = "zhusers"

  primary_key type: :serial

  timestamps
end

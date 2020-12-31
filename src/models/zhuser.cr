require "./_models"

class CV::Models::Zhuser
  include Clear::Model
  self.table = "zhusers"

  primary_key type: :serial

  timestamps
end

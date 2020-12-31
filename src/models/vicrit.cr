require "./_models"
require "./viuser"

class CV::Models::Vicrit
  include Clear::Model
  self.table = "vicrits"

  primary_key type: :serial

  belongs_to viuser : Viuser, foreign_key_type: Int32

  timestamps
end

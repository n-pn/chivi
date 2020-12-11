require "./_models"
require "./serial"

class Chivi::Source
  include Clear::Model
  self.table = "sources"

  column id : Int32, primary: true, presence: false

  column name : String
  column sbid : String

  column _index : Int32, presence: false
  column status : Int32, presence: false

  column update_at : Int32, presence: false
  column access_at : Int32, presence: false

  column word_count : Int32, presence: false
  column chap_count : Int32, presence: false

  column view_count : Int32, presence: false
  column read_count : Int32, presence: false
end

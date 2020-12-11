require "./_models"
require "./serial"

class Chivi::Source
  include Clear::Model
  self.table = "sources"

  column id : Int32, primary: true, presence: false

  column name : String
  column sbid : String

  column _index : Int32 = 0
  column status : Int32 = 0

  column update : Int32 = 0
  column access : Int32 = 0

  column word_count : Int32 = 0
  column chap_count : Int32 = 0

  column view_count : Int32 = 0
  column read_count : Int32 = 0
end

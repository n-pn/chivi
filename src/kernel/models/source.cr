require "./_models"
require "./serial"

class Chivi::Source
  include Clear::Model
  self.table = "sources"

  primary_key type: :serial
  belongs_to serial : Serial, foreign_key_type: Int32

  column name : String
  column sbid : String

  column author : String?
  column btitle : String?
  column bgenre : String?

  column intro : String?
  column cover : String?

  column _order : Int32, presence: false
  column status : Int32, presence: false

  column update_at : Int64, presence: false
  column access_at : Int64, presence: false

  column word_count : Int32, presence: false
  column chap_count : Int32, presence: false

  column view_count : Int32, presence: false
  column read_count : Int32, presence: false

  # def self.upsert!
  # end
end

require "./_models"
require "./serial"
require "./source"

# Chapter info
class Chivi::Chinfo
  include Clear::Model
  self.table = "chinfos"

  primary_key type: :serial
  timestamps

  belongs_to serial : Serial, foreign_key_type: Int32
  belongs_to source : Source, foreign_key_type: Int32

  column scid : String
  column _index : Int32
  column status : Int32

  column zh_title : String
  column vi_title : String
  column vi_label : String
  column url_slug : String

  column update_at : Int64, presence: false
  column access_at : Int64, presence: false

  column word_count : Int32, presence: false
  column read_count : Int32, presence: false
end

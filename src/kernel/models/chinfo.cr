require "./_models"
require "./serial"
require "./source"

# Chapter info
class Chivi::Chinfo
  include Clear::Model
  self.table = "chinfos"

  belongs_to Serial
  belongs_to Source

  column scid : String
  column _index : Int32
  column status : Int32

  column zh_title : String
  column vi_title : String
  column vi_label : String
  column url_slug : String

  column update_at : Int32, presence: false
  column access_at : Int32, presence: false

  column word_count : Int32, presence: false
  column read_count : Int32, presence: false
end

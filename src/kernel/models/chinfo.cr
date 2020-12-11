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
  column _idx : Int32

  column title_zh : String
  column title_vi : String
  column label_vi : String
  column url_slug : String

  column word_count : Int32 = 0
  column read_count : Int32 = 0
end

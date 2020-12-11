require "./_models"
require "./author"
require "./btitle"
require "./bgenre"

class Chivi::Serial
  include Clear::Model
  self.table = "serials"

  column id : Int32, primary: true, presence: false

  column bhash : String = ""
  column bslug : String = ""

  belongs_to author : Author
  belongs_to btitle : Btitle

  column bgenre_ids : Array(Int32)
  column source_ids : Array(Int32)

  column intro_zh : String
  column intro_sn : String
  column intro_vi : String

  column hidden : Int32 = 0
  column status : Int32 = 0
  column update : Int32 = 0
  column access : Int32 = 0

  column voters_zh : Int32 = 0 # seed voters (yousuu or custom)
  column voters_vi : Int32 = 0 # chivi genuine voters

  column rating_zh : Int32 = 0 # seed rating (yousuu or custom)
  column rating_vi : Int32 = 0 # chivi genuine rating

  column word_count : Int32 = 0
  column chap_count : Int32 = 0

  column view_count : Int32 = 0
  column read_count : Int32 = 0

  column review_count : Int32 = 0
  column follow_count : Int32 = 0

  column popularity : Int32 = 0 # to be sorted by

  column cover_name : String
  column yousuu_bid : String
  column origin_url : String
end

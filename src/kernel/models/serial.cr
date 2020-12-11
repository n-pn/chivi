require "./_models"
require "./author"
require "./btitle"
require "./bgenre"

class Chivi::Serial
  include Clear::Model
  self.table = "serials"

  column id : Int32, primary: true, presence: false

  column hv_slug : String
  column vi_slug : String

  belongs_to author : Author
  belongs_to btitle : Btitle

  column bgenre_ids : Array(Int32), presence: false
  # column source_ids : Array(Int32), presence: false

  column zh_intro : String
  column vi_intro : String
  column intro_by : String # source name

  column hidden : Int32, presence: false
  column status : Int32, presence: false

  column update_at : Int32, presence: false
  column access_at : Int32, presence: false

  column zh_voters : Int32, presence: false # seed voters (yousuu or custom)
  column zh_rating : Int32, presence: false # seed rating (yousuu or custom)

  column vi_voters : Int32, presence: false # chivi genuine voters
  column vi_rating : Int32, presence: false # chivi genuine rating

  column word_count : Int32, presence: false
  column chap_count : Int32, presence: false

  column view_count : Int32, presence: false
  column read_count : Int32, presence: false

  column review_count : Int32, presence: false
  column follow_count : Int32, presence: false

  column popularity : Int32, presence: false # to be sorted by

  column cover_name : String
  column yousuu_bid : String
  column origin_url : String
end

class CV::Yslist < Granite::Base
  connection pg
  table yslists

  belongs_to :ysuser
  has_many :yscrit

  column id : Int64, primary: true
  timestamps

  column zh_name : String # original list name
  column vi_name : String # translated name

  column zh_desc : String # original description
  column vi_desc : String # translated description

  column aim_at : String = "male" # target demographic: male or female

  column bumped : Int64 = 0 # list checked at by minutes from epoch
  column mftime : Int64 = 0 # list changed at by seconds from epoch

  column like_count : Int32 = 0
  column book_count : Int32 = 0
  column view_count : Int32 = 0
end

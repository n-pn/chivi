class CV::Yslist < Granite::Base
  connection pg
  table yslists

  belongs_to :ysuser, foreign_key: ysuser_id : Int32

  column id : Int32, primary: true
  timestamps

  column origin_id : String # origianl yousuu booklist string id

  column zh_name : String # original list name
  column vi_name : String # translated name

  column zh_desc : String # original description
  column vi_desc : String # translated description

  column channel : String = "male" # target audience: male or female

  column mftime : Int64 = 0 # list changed at by seconds from epoch
  column bumped : Int64 = 0 # list checked at by minutes from epoch

  column like_count : Int32 = 0
  column book_count : Int32 = 0
  column view_count : Int32 = 0
end

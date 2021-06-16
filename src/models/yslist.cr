require "./_setup"

class CV::Yslist
  include Clear::Model

  primary_key type: serial

  column ysuser_id : Int32  # link to ysusers table
  column origin_id : String # origianl yousuu booklist string id

  column zh_name : String # original name
  column vi_name : String # translation

  column zh_desc : String? # original description
  column vi_desc : String? # converted desciption

  column target : String # target audience: male or female

  column mftime : Int64, presence: false # list changed at by seconds from epoch
  column bumped : Int32, presence: false # list checked at by minutes from epoch

  column like_count : Int32, presence: false
  column book_count : Int32, presence: false
  column view_count : Int32, presence: false
end

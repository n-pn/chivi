require "./_setup"

class CV::Yscrit
  include Clear::Model

  primary_key type: serial

  column ysuser_id : Int32  # link to ysusers table
  column yslist_id : Int32? # link to yslists table

  column origin_id : String # origianl yousuu booklist string id

  column zh_name : String # original name
  column vi_name : String # translation

  column starred : Int32 # voting 1 2 3 4 5 stars

  column zh_text : String # original content
  column vi_html : String # converted content

  column mftime : Int64, presence: false # list changed at by seconds from epoch
  column bumped : Int32, presence: false # list checked at by minutes from epoch

  column like_count : Int32, presence: false
  column repl_count : Int32, presence: false # reply count
end

class CV::Yscrit < Granite::Base
  connection pg
  table yscrits

  belongs_to :ysuser
  belongs_to :yslist

  column id : Int32, primary: true
  timestamps

  column origin_id : String # original yousuu comment string id
  column ysbook_id : Int32  # original yoosuu book id

  column starred : Int32 = 3 # voting 1 2 3 4 5 stars

  column zh_text : String = "" # orginal comment
  column vi_html : String = "" # translated comment

  column mftime : Int64 = 0 # list changed at by seconds from epoch
  column bumped : Int64 = 0 # list checked at by minutes from epoch

  column like_count : Int32 = 0
  column repl_count : Int32 = 0 # reply count, optional
end

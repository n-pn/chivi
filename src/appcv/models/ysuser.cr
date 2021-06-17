class CV::Ysuser < Granite::Base
  connection pg
  table ysusers

  column id : Int32, primary: true
  timestamps

  column origin_id : String

  column zh_name : String
  column vi_name : String

  column like_count : Int32 = 0 # TBD: total list like_count or direct like count
  column list_count : Int32 = 0 # book list count
  column crit_count : Int32 = 0 # review count
end

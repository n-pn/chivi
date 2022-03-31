class CV::Ysbook
  include Clear::Model

  self.table = "ysbooks"
  primary_key

  column nvinfo_id : Int64 = 0

  column btitle : String = ""
  column author : String = ""

  # ranking

  column voters : Int32 = 0 # yousuu book voters
  column scores : Int32 = 0 # yousuu users ratings * voters

  # book info
  column utime : Int64 = 0_i64 # yousuu book update time
  column word_count : Int32 = 0

  # origin
  column pub_name : String = "" # original publisher name, extract from link
  column pub_link : String = "" # original publisher novel page

  # counters

  column crit_count : Int32 = 0 # fetched reviews
  column list_count : Int32 = 0 # fetched book lists

  column crit_total : Int32 = 0 # total reviews
  column list_total : Int32 = 0 # total book lists

  # for crawlers

  column info_stime : Int64 = 0_i64
  column crit_stime : Int64 = 0_i64
  column list_stime : Int64 = 0_i64

  timestamps # created_at and updated_at

  #########################################

end

class CV::Ysbook
  include Clear::Model

  self.table = "ysbooks"
  primary_key

  column atime : Int64 = 0_i64 # yousuu book crawl time
  column utime : Int64 = 0_i64 # yousuu book update time

  # ranking

  column voters : Int32 = 0 # yousuu book voters
  column scores : Int32 = 0 # yousuu users ratings * voters

  # counters

  column word_count : Int32 = 0 # total words count from yousuu
  column crit_count : Int32 = 0 # yousuu reviews count
  column list_count : Int32 = 0 # yousuu booklists count

  column pub_name : String = "" # original publisher name, extract from link
  column pub_link : String = "" # original publisher novel page

  timestamps # created_at and updated_at

  #########################################

end

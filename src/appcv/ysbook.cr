require "./shared/seed_data"

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
  column status : Int32 = 0
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

  ################

  def set_bindex(bindex : Seed::Bindex)
    self.stime = bindex.stime

    self.btitle = bindex.btitle
    self.author = bindex.author
  end

  def set_rating(rating : Seed::Rating)
    self.voters = scores.voters
    self.scores = scores.voters &* scores.rating
  end

  def set_ystats(ystats : Seed::Ystats)
    self.list_total = ystats.list_count
    self.crit_total = ystats.crit_count

    self.list_count = ystats.list_count if self.list_count == 0
    self.crit_count = ystats.crit_count if self.crit_count == 0
  end

  def set_origin(origin : Seed::Origin)
    self.pub_name = origin.pub_name
    self.pub_link = origin.pub_link
  end

  def set_mftime(mftime : Seed::Mfitime)
    self.utime = mftime.update
  end

  #########################################

  def self.upsert!(id : Int64)
    find({id: id}) || new({id: id})
  end
end

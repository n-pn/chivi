require "./shared/seed_data"

class CV::Ysbook
  include Clear::Model

  self.table = "ysbooks"
  primary_key

  belongs_to nvinfo : Nvinfo

  # seed data

  column btitle : String = ""
  column author : String = ""

  column bcover : String = ""
  column bintro : String = ""
  column bgenre : String = ""

  # ranking

  column voters : Int32 = 0 # yousuu book voters
  column scores : Int32 = 0 # yousuu users ratings * voters

  # book info
  column status : Int32 = 0
  column shield : Int32 = 0

  column utime : Int64 = 0_i64 # yousuu book update time
  column stime : Int64 = 0_i64

  # origin

  column pub_name : String = "" # original publisher name, extract from link
  column pub_link : String = "" # original publisher novel page

  # counters

  column word_count : Int32 = 0
  column crit_count : Int32 = 0 # fetched reviews
  column list_count : Int32 = 0 # fetched book lists

  column crit_total : Int32 = 0 # total reviews
  column list_total : Int32 = 0 # total book lists

  # for crawlers

  column crit_stime : Int64 = 0_i64
  column list_stime : Int64 = 0_i64

  timestamps # created_at and updated_at

  def update_nvinfo : Nil
    return if nvinfo.ysbook_id != self.id && lesser_source?(nvinfo.ysbook_id)

    nvinfo.set_zintro(self.bintro.split('\t'))
    nvinfo.set_genres(self.bgenre.split('\t'))
    nvinfo.set_covers(self.bcover)

    nvinfo.set_utime(self.utime)
    nvinfo.set_status(self.status)
    nvinfo.set_shield(self.shield)
    nvinfo.fix_scores!(self.voters, self.scores)

    nvinfo.ysbook_id = self.id
    nvinfo.save!
  end

  def lesser_source?(other_id : Int64)
    return false if other_id == 0 || !(other = Ysbook.find({id: other_id}))

    self.voters <= other.voters.tap do |lesser|
      Log.info { "!! override: #{other_id} (#{other.voters}) \
                   => #{self.id} (#{self.voters})".colorize.yellow } if lesser
    end
  end

  #########################################

  def self.upsert!(id : Int64)
    find({id: id}) || new({id: id})
  end
end

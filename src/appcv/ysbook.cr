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

  timestamps # created_at and updated_at

  def set_bcover(bcover : String, force : Bool = false) : Nil
    return unless force || self.bcover.empty?
    self.bcover = bcover
    self.nvinfo.set_covers(bcover)
  end

  def set_bintro(bintro : Array(String), force : Bool = false) : Nil
    return unless force || self.bintro.empty?
    self.bintro = bintro.join('\n')
    self.nvinfo.set_zintro(bintro)
  end

  def set_genres(genres : Array(String), force : Bool = false) : Nil
    return unless force || self.bgenre.empty?
    self.bgenre = genres.join('\t')
    self.nvinfo.set_genres(genres)
  end

  def set_mftime(mftime : Int64, force : Bool = false) : Nil
    return unless force || self.utime < mftime
    self.utime = mftime
    self.nvinfo.set_utime(mftime)
  end

  def set_status(status : Int32, force : Bool = false) : Nil
    return unless force || self.status < status
    self.status = status
    self.nvinfo.set_status(status)
  end

  def set_shield(shield : Int32, force : Bool = false) : Nil
    return unless force || self.shield < shield
    self.shield = shield
    self.nvinfo.set_shield(shield)
  end

  def update_nvinfo : Nil
    return if nvinfo.ysbook_id != self.id && lesser_source?(nvinfo.ysbook_id || 0_i64)
    nvinfo.fix_scores!(self.voters, self.scores)
    nvinfo.ysbook_id = self.id
    nvinfo.save!
  end

  def lesser_source?(other_id : Int64)
    return false if other_id == 0 || !(other = Ysbook.find({id: other_id}))
    return true if self.voters <= other.voters

    puts "!! override: #{other_id} (#{other.voters}) \
          => #{self.id} (#{self.voters})".colorize.yellow

    false
  end

  #########################################

  def self.upsert!(id : Int64)
    find({id: id}) || new({id: id})
  end
end

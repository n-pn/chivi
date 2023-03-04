require "./_base"

class YS::Ysbook
  include Clear::Model
  self.table = "ysbooks"

  primary_key type: :serial

  column nvinfo_id : Int32 = 0

  column btitle : String = ""
  column author : String = ""

  column cover : String = ""
  column intro : String = ""

  column genre : String = ""
  column btags : Array(String) = [] of String

  column voters : Int32 = 0
  column rating : Int32 = 0

  column status : Int32 = 0
  column shield : Int32 = 0

  column book_mtime : Int64 = 0_i64 # yousuu book update time
  column info_rtime : Int64 = 0_i64

  column word_count : Int32 = 0

  column crit_total : Int32 = 0 # total reviews
  column crit_count : Int32 = 0 # fetched reviews

  column list_total : Int32 = 0 # total book lists
  column list_count : Int32 = 0 # fetched book lists

  column sources : Array(String) = [] of String

  timestamps # created_at and updated_at

  # def lesser_source?(other_id : Int64)
  #   return false if other_id == 0 || !(other = Ysbook.find({id: other_id}))
  #   return true if self.voters <= other.voters

  #   puts "!! override: #{other_id} (#{other.voters}) \
  # => #{self.id} (#{self.voters})".colorize.yellow

  #   false
  # end

  def create_wnovel!
    # TODO
  end

  #########################################

  def self.load(y_bid : Int32)
    find({id: y_bid}) || new({id: y_bid})
  end

  def self.upsert!(raw_data : EmbedBook, force : Bool = false)
    model = load(raw_data.id)

    model.btitle = raw_data.btitle
    model.author = raw_data.author

    model.create_wnovel! if force

    model.tap(&.save!)
  end

  def self.upsert!(raw_data : RawYsBook, force : Bool = false)
    model = load(raw_data.id)

    model.btitle = raw_data.btitle
    model.author = raw_data.author

    model.cover = raw_data.cover
    model.intro = raw_data.intro

    model.genre = raw_data.genre
    model.btags = raw_data.btags

    model.voters = raw_data.voters
    model.rating = raw_data.rating

    model.status = raw_data.status
    model.shield = raw_data.shield

    model.book_mtime = raw_data.book_mtime
    model.info_rtime = raw_data.info_rtime

    model.word_count = raw_data.word_count
    model.crit_total = raw_data.crit_total
    model.list_total = raw_data.list_total

    model.sources = raw_data.sources

    model.create_wnovel! if force

    model.tap(&.save!)
  end
end

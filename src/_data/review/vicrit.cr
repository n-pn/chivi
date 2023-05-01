require "../wnovel/wninfo"
require "../member/viuser"

class CV::Vicrit
  include Clear::Model
  self.table = "vicrits"

  primary_key type: :serial

  column nvinfo_id : Int32
  column viuser_id : Int32
  column vilist_id : Int32

  column stars : Int32 = 3

  column itext : String = ""
  column ohtml : String = ""

  # column _sort : Int32 = 0 # manage by database
  column _flag : Int32 = 0

  column btags : Array(String) = [] of String

  column like_count : Int32 = 0
  column repl_count : Int32 = 0

  column changed_at : Time? = nil

  timestamps

  scope :sort_by do |order|
    case order
    when "ctime" then self.order_by(id: :desc)
    when "utime" then self.order_by(id: :desc)
    when "likes" then self.order_by(like_count: :desc, stars: :desc)
    else              self.order_by(_sort: :desc, stars: :desc)
    end
  end

  def patch!(itext : String, stars : Int32, btags : Array(String))
    self.itext = itext
    self.stars = stars
    self.btags = btags
    self.ohtml = PostUtil.md_to_html(itext)
    self.save!
  end

  def canonical_path
    wninfo = Wninfo.load!(self.nvinfo_id)
    "#{wninfo.canonical_path}/uc/v#{self.id}"
  end

  ###

  def self.load!(id : Int32)
    find!({id: id})
  end

  def self.inc_repl_count!(id : Int32, value = 1)
    PGDB.exec <<-SQL, value, id
      update vicrits
      set repl_count = repl_count + $1
      where id = $2
      SQL
  end

  ####
end

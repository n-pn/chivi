require "./nv_info"
require "./g_vuser"
require "./vi_list"

class CV::Vicrit
  include Clear::Model
  self.table = "vicrits"

  primary_key type: :serial

  belongs_to viuser : Viuser, foreign_key_type: Int32
  belongs_to nvinfo : Nvinfo

  belongs_to vilist : Vilist?, foreign_key_type: Int32

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

  scope :filter_book do |book|
    book ? where("nvinfo_id = ?", book) : self
  end

  scope :filter_user do |user|
    user ? where("viuser_id = ?", user) : self
  end

  scope :filter_list do |list|
    list ? where("vilist_id = ?", list) : self
  end

  scope :filter_tags do |tags|
    tags ? where("btags @> ?", tags) : self
  end

  scope :sort_by do |order|
    case order
    when "ctime" then self.order_by(id: :desc)
    when "likes" then self.order_by(like_count: :desc)
    else              self.order_by(_sort: :desc)
    end
  end

  def patch!(input : String, stars : String | Int32, btags : String)
    self.itext = input
    self.ohtml = PostUtil.md_to_html(input)
    self.stars = stars.to_i
    self.btags = btags.split(/\s*,\s*/, remove_empty: true)

    self.save!
  end
end

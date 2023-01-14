require "../wnovel/nv_info"
require "../member/vi_user"

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

  scope :sort_by do |order|
    case order
    when "ctime" then self.order_by(id: :desc)
    when "likes" then self.order_by(like_count: :desc)
    else              self.order_by(_sort: :desc)
    end
  end

  def patch!(input : String, stars : String, btags : String)
    patch!(input, stars.to_i, btags.split(/\s*,\s*/, remove_empty: true))
  end

  def patch!(@itext : String, @stars : Int32, @btags : Array(String))
    self.ohtml = PostUtil.md_to_html(itext)
    self.save!
  end
end

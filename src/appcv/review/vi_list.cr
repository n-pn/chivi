require "../member/vi_user"

class CV::Vilist
  include Clear::Model
  self.table = "vilists"

  primary_key type: :serial
  belongs_to viuser : Viuser

  column title : String = ""
  column tslug : String = ""

  column dtext : String = ""
  column dhtml : String = ""

  column klass : String = "male"

  column covers : Array(String) = [] of String
  column genres : Array(String) = [] of String

  column _sort : Int32 = 0
  column _flag : Int32 = 0
  column _bump : Int32 = 0

  column book_count : Int32 = 0
  column like_count : Int32 = 0
  column star_count : Int32 = 0
  column view_count : Int32 = 0

  timestamps

  scope :filter_user do |viuser_id|
    viuser_id ? where("viuser_id = #{viuser_id}") : self
  end

  scope :sort_by do |order|
    case order
    when "ctime" then self.order_by(id: :desc)
    when "likes" then self.order_by(like_count: :desc)
    when "stars" then self.order_by(star_count: :desc)
    else              self.order_by(_sort: :desc)
    end
  end
end

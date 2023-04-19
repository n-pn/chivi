require "../member/viuser"

require "../../_util/text_util"
require "../../_util/post_util"

class CV::Vilist
  include Clear::Model
  self.table = "vilists"

  primary_key type: :serial
  column viuser_id : Int32 = 0

  column title : String = ""
  column tslug : String = ""

  column dtext : String = ""
  column dhtml : String = ""

  column klass : String = ""

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

  scope :sort_by do |order|
    case order
    when "ctime" then self.order_by(id: :desc)
    when "likes" then self.order_by(like_count: :desc)
    when "stars" then self.order_by(star_count: :desc)
    else              self.order_by(_sort: :desc)
    end
  end

  def set_title(title : String)
    self.title = title
    self.tslug = TextUtil.slugify(title)
  end

  def set_intro(input : String)
    self.dtext = input
    self.dhtml = PostUtil.md_to_html(input)
  end

  ###
  def self.load!(id : Int32)
    self.find({id: id}) || begin
      raise "not found" if id >= 0

      vuser = Viuser.load!(-id)

      model = new({id: id, viuser_id: vuser.id})

      model.set_title "Đánh giá truyện chung của @#{vuser.uname}"
      model.set_intro "Tổng hợp đánh giá các bộ truyện không theo đề tài cụ thể"

      model.tap(&.save!)
    end
  end

  def self.preload(ids : Enumerable(Int32))
    ids.empty? ? [] of self : query.where { id.in?(ids) }
  end
end

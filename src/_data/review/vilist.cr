require "../member/viuser"

require "../../_util/text_util"
require "../../_util/post_util"

class CV::Vilist
  include Clear::Model
  self.table = "vilists"

  primary_key type: :serial
  column viuser_id : Int32 = 0

  column title : String = ""
  column tslug : String = "" # autogen

  column dtext : String = ""
  column dhtml : String = "" # autogen

  column klass : String = ""

  column covers : Array(String) = [] of String # gen by script
  column genres : Array(String) = [] of String # gen by script

  column _bump : Int32 = 0 # TODO: rename to checked_at
  column _sort : Int32 = 0 # TODO: move to database
  column _flag : Int32 = 0 # ???

  column book_count : Int32 = 0
  column like_count : Int32 = 0

  column star_count : Int32 = 0 # track count
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

  def patch!(title : String, dtext : String, klass : String, persist : Bool = true)
    self.set_title(title)
    self.set_ldesc(dtext)
    self.klass = klass

    self.save! if persist
  end

  def set_title(title : String)
    self.title = title
    self.tslug = TextUtil.slugify(title)
  end

  def set_ldesc(dtext : String)
    self.dtext = dtext
    self.dhtml = PostUtil.md_to_html(dtext)
  end

  ###
  def self.load!(id : Int32)
    self.find({id: id}) || begin
      raise "Thư đơn không tồn tại!" if id >= 0

      model = new({id: id, viuser_id: -id})
      model.patch!(
        title: "Đánh giá truyện chung của @[#{Viuser.get_uname(-id)}]",
        dtext: "Tổng hợp đánh giá các bộ truyện không theo đề tài cụ thể",
        klass: "",
        persist: true,
      )

      model
    end
  end

  def self.preload(ids : Enumerable(Int32))
    ids.empty? ? [] of self : query.where("id = any(?)", ids)
  end

  def self.inc_counter(id : Int32, name : String, value = 1)
    PGDB.exec "update vilists set #{name} = #{name} + $1 where id = $2", value, id
  end

  def self.dec_counter(id : Int32, name : String, value = 1)
    PGDB.exec "update vilists set #{name} = #{name} - $1 where id = $2", value, id
  end
end

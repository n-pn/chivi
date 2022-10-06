require "./ys_crit"
require "./ys_user"

class YS::Ysrepl
  include Clear::Model

  self.table = "ysrepls"
  primary_key
  column origin_id : String

  belongs_to ysuser : Ysuser
  belongs_to yscrit : Yscrit

  column ztext : String = "" # orginal comment
  column vhtml : String = "" # translated comment

  column stime : Int64 = 0 # list checked at by minutes from epoch

  column like_count : Int32 = 0
  column repl_count : Int32 = 0 # reply count, optional

  timestamps

  scope :filter_yscrit do |yscrit_id|
    yscrit_id ? where("yscrit_id = #{yscrit_id}") : self
  end

  scope :filter_ysuser do |ysuser_id|
    ysuser_id ? where("ysuser_id = #{ysuser_id}") : self
  end

  scope :sort_by do |order|
    case order
    when "ctime" then self.order_by(id: :desc)
    when "likes" then self.order_by(like_count: :desc)
    else              self.order_by(created_at: :desc)
    end
  end

  def set_ztext(ztext : String)
    return if ztext.empty?
    self.ztext = ztext
    self.fix_vhtml
  end

  def fix_vhtml(dname = self.yscrit.nvinfo.dname)
    self.vhtml = CV::BookUtil.cv_lines(ztext, dname, mode: :html)
  end

  ##############

  def self.gen_id(origin_id : String)
    origin_id[12..].to_i64(base: 16)
  end

  def self.upsert!(origin_id : String, created_at : Time)
    find({origin_id: origin_id}) || begin
      new({id: gen_id(origin_id), origin_id: origin_id, created_at: created_at})
    end
  end
end

class CV::Ysrepl
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

  def cvdata(dname = self.yscrit.nvinfo.dname, mode = 1)
    lines = self.ztext.split("\n").map(&.strip).reject(&.empty?)
    cvmtl = MtCore.generic_mtl(dname)
    lines.map { |line| cvmtl.cv_plain(line, mode: mode).to_str }.join("\n")
  end

  def self.get!(id : Int64, created_at : Time)
    find({id: id}) || new({id: id, created_at: created_at})
  end
end

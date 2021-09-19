class CV::Yscrit
  include Clear::Model

  self.table = "yscrits"
  primary_key

  belongs_to cvbook : Cvbook
  belongs_to ysbook : Ysbook

  belongs_to ysuser : Ysuser
  belongs_to yslist : Yslist?

  has_many ysrepls : Ysrepl

  column origin_id : String

  column stars : Int32 = 3 # voting 1 2 3 4 5 stars

  column ztext : String = "" # orginal comment
  column vhtml : String = "" # translated comment

  column bumped : Int64 = 0 # list checked at by minutes from epoch
  column mftime : Int64 = 0 # list changed at by seconds from epoch

  column like_count : Int32 = 0
  column repl_count : Int32 = 0 # reply count, optional

  timestamps

  scope :filter_cvbook do |cvbook_id|
    cvbook_id ? where("cvbook_id = #{cvbook_id}") : self
  end

  scope :filter_ysuser do |ysuser_id|
    ysuser_id ? where("ysuser_id = #{ysuser_id}") : self
  end

  scope :sort_by do |order|
    case order
    when "ctime" then self.order_by(id: :desc)
    when "likes" then self.order_by(like_count: :desc)
    when "stars" then self.order_by(stars: :desc, like_count: :desc)
    else              self.order_by(created_at: :desc)
    end
  end

  def cvdata(bname = self.cvbook.bhash, mode = 1)
    lines = self.ztext.split("\n").map(&.strip).reject(&.empty?)
    libcv = MtCore.generic_mtl(bname)
    lines.map { |line| libcv.cv_plain(line, mode: mode).to_str }.join("\n")
  end

  def self.get!(id : Int64, created_at : Time)
    find({id: id}) || new({id: id, created_at: created_at})
  end
end

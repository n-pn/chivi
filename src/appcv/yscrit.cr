class CV::Yscrit
  include Clear::Model
  self.table = "yscrits"

  primary_key
  column origin_id : String = ""

  belongs_to nvinfo : Nvinfo
  belongs_to ysbook : Ysbook
  belongs_to ysuser : Ysuser
  belongs_to yslist : Yslist?

  column stars : Int32 = 3 # voting 1 2 3 4 5 stars
  column _sort : Int32 = 0

  column ztext : String = "" # orginal comment
  column vhtml : String = "" # translated comment

  column ztags : Array(String) = [] of String
  column vtags : Array(String) = [] of String

  column utime : Int64 = 0 # list changed at by seconds from epoch
  column stime : Int64 = 0 # list checked at by minutes from epoch

  column repl_total : Int32 = 0
  column repl_count : Int32 = 0
  column like_count : Int32 = 0

  timestamps

  scope :filter_nvinfo do |nvinfo_id|
    nvinfo_id ? where("nvinfo_id = #{nvinfo_id}") : self
  end

  scope :filter_ysuser do |ysuser_id|
    ysuser_id ? where("ysuser_id = #{ysuser_id}") : self
  end

  scope :filter_yslist do |yslist_id|
    yslist_id ? where("yslist_id = #{yslist_id}") : self
  end

  scope :filter_labels do |vtag|
    vtag ? where("vtags @> ?", [vtag]) : self
  end

  scope :sort_by do |order|
    case order
    when "ctime" then self.order_by(id: :desc)
    when "likes" then self.order_by(like_count: :desc)
    when "score" then self.order_by(_sort: :desc, stars: :desc)
    when "stars" then self.order_by(stars: :desc, like_count: :desc)
    else              self.order_by(utime: :desc)
    end
  end

  #############
  #
  def fix_sort!
    self._sort = self.stars &* self.stars &* self.like_count
    self._sort &+ self.repl_count &* self.stars
  end

  def set_ztext(ztext : String)
    return if ztext.empty?
    self.ztext = ztext
    self.fix_vhtml
  end

  def set_tags(tags : Array(String), force : Bool = false)
    return unless force || self.ztags.empty?
    self.ztags = tags
    self.fix_vtags
  end

  def fix_vhtml(dname = self.nvinfo.dname)
    self.vhtml = BookUtil.cv_lines(ztext, dname, mode: :html)
  end

  MTL = MtCore.generic_mtl("!labels")

  def fix_vtags
    self.vtags = self.ztags.map { |x| MTL.translate(x) }
  end

  ###################

  def self.gen_id(origin_id : String)
    origin_id[12..].to_i64(base: 16)
  end

  def self.upsert!(origin_id : String, created_at : Time)
    find({origin_id: origin_id}) || begin
      new({id: gen_id(origin_id), origin_id: origin_id, created_at: created_at})
    end
  end
end

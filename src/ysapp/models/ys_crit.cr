require "compress/zip"
require "./ys_list"

class YS::Yscrit
  include Clear::Model
  self.table = "yscrits"

  primary_key
  column origin_id : String = ""

  belongs_to nvinfo : CV::Nvinfo
  belongs_to ysbook : CV::Ysbook
  belongs_to ysuser : Ysuser
  belongs_to yslist : Yslist?

  column stars : Int32 = 3 # voting 1 2 3 4 5 stars
  column _sort : Int32 = 0

  # column ztext : String = "" # translated comment
  column vhtml : String = "" # translated comment

  getter ztext : String { load_ztext_from_disk }

  def load_ztext_from_disk : String
    zip_file = "var/ysapp/crits/#{self.ysbook_id}-zh.zip"

    Compress::Zip::File.open(zip_file) do |zip|
      zip[origin_id + ".txt"]?.try(&.open(&.gets_to_end)) || "$$$"
    end
  rescue err
    Log.error(exception: err) { "error loading #{origin_id} of #{ysbook_id}" }
    "XXX"
  end

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
    when "utime" then self.order_by(utime: :desc)
    when "likes" then self.order_by(like_count: :desc, stars: :desc)
    else              self.order_by(_sort: :desc, stars: :desc)
    end
  end

  #############

  def fix_sort!
    self._sort = self.stars &* self.stars &* self.like_count
    self._sort &+ self.repl_count &* self.stars
  end

  def set_tags(tags : Array(String), force : Bool = false)
    return unless force || self.ztags.empty?
    self.ztags = tags
    self.fix_vtags
  end

  def fix_vhtml(ztext : String, dname = self.nvinfo.dname)
    self.vhtml = CV::BookUtil.cv_lines(ztext, dname, mode: :html)
  end

  def fix_vtags(mtl = CV::MtCore.generic_mtl("!labels"))
    self.vtags = self.ztags.map { |x| mtl.translate(x) }
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

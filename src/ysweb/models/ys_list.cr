require "./ys_user"
require "./ys_crit"

class YS::Yslist
  include Clear::Model

  self.table = "yslists"
  primary_key

  belongs_to ysuser : Ysuser
  # has_many yscrits : Yscrit, foreign_key: "yslist_id"
  # has_many nvinfos : CV::Nvinfo, through: "yscrits"

  column origin_id : String = ""

  column zname : String = "" # original list name
  column vname : String = "" # translated name

  column vslug : String = "" # to search

  column zdesc : String = "" # original description
  column vdesc : String = "" # translated description

  column klass : String = "male" # target demographic: male or female

  column covers : Array(String) = [] of String
  column genres : Array(String) = [] of String

  column utime : Int64 = 0 # list checked at by minutes from epoch
  column stime : Int64 = 0 # list changed at by seconds from epoch

  column _bump : Int32 = 0 # mapped from raw yousuu praiseAt column
  column _sort : Int32 = 0 # sort list by custom algorithm

  column book_count : Int32 = 0
  column book_total : Int32 = 0

  column like_count : Int32 = 0
  column view_count : Int32 = 0
  column star_count : Int32 = 0

  timestamps

  scope :filter_ysuser do |ysuser_id|
    ysuser_id ? where("ysuser_id = #{ysuser_id}") : self
  end

  scope :filter_string do |qs|
    qs ? where("vslug LIKE '%-#{CV::BookUtil.scrub_vname(qs, '-')}-%'") : self
  end

  scope :sort_by do |order|
    case order
    when "ctime" then self.order_by(id: :desc)
    when "utime" then self.order_by(utime: :desc)
    when "likes" then self.order_by(like_count: :desc)
    when "stars" then self.order_by(star_count: :desc)
    when "views" then self.order_by(view_count: :desc)
    else              self.order_by(_sort: :desc)
    end
  end

  ####################

  def set_name(zname : String) : Nil
    self.zname = zname
    self.fix_vname
  end

  def set_desc(zdesc : String)
    return if zdesc.empty?
    self.zdesc = zdesc
    self.fix_vdesc
  end

  def fix_vname(mtl = CV::MtCore.generic_mtl("!yousuu"))
    vdict = mtl.dicts.last
    vdict.set(ysuser.zname, [ysuser.vname], ["nr"])

    self.vname = mtl.translate(self.zname)
    self.vslug = "-" + CV::BookUtil.scrub_vname(self.vname, "-") + "-"
    vdict.set(ysuser.zname, [""])
  end

  def fix_vdesc
    self.vdesc = CV::BookUtil.cv_lines(zdesc, "combine", mode: :text)
  end

  def fix_sort!
    self._sort = self.book_total &* (self.like_count &+ self.star_count &+ 1) &+ self.view_count
  end

  ##################

  def self.gen_id(origin_id : String)
    origin_id[-7..-1].to_i64(base: 16)
  end

  def self.upsert!(origin_id : String, created_at : Time)
    find({origin_id: origin_id}) || new({
      id: gen_id(origin_id),

      origin_id:  origin_id,
      created_at: created_at,
    })
  end

  CACHE_INT = CV::RamCache(Int64, self).new

  def self.load!(id : Int64)
    CACHE_INT.get(id) { find!({id: id}) }
  end
end

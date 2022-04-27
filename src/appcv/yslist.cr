class CV::Yslist
  include Clear::Model

  self.table = "yslists"
  primary_key

  belongs_to ysuser : Ysuser
  # has_many yscrits : Yscrit
  # has_many nvinfos : Nvinfo, through: "yscrits"

  column origin_id : String = ""

  column zname : String = "" # original list name
  column vname : String = "" # translated name

  column vslug : String = "" # to search

  column zdesc : String = "" # original description
  column vdesc : String = "" # translated description

  column klass : String = "male" # target demographic: male or female

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

  MTL = MtCore.generic_mtl

  def set_name(zname : String) : Nil
    self.zname = zname
    self.vname = MTL.translate(self.zname)
    self.vslug = "-" + BookUtil.scrub_vname(self.vname) + "-"
  end

  def set_desc(zdesc : String)
    return if zdesc.empty?

    self.zdesc = zdesc
    self.vdesc = zdesc.split('\n').map { |x| MTL.translate(x) }.join('\n')
  end

  def fix_sort!
    self._sort = self.book_total &+ self.like_count &+ self.star_count &+ self.view_count
  end

  ##################

  def self.get!(id : Int64, created_at : Time)
    find({id: id}) || new({id: id, created_at: created_at})
  end

  CACHE_INT = RamCache(Int64, self).new

  def self.load!(id : Int64)
    CACHE_INT.get(id) { find!({id: id}) }
  end
end

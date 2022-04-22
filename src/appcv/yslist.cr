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

  timestamps

  MTL = MtCore.generic_mtl

  def set_name(zname : String)
    self.zname = zname
    self.vname = MTL.translate(self.zname)
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

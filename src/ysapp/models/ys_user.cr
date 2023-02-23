require "./_base"

class YS::Ysuser
  include Clear::Model

  self.table = "ysusers"
  primary_key

  column origin_id : Int32

  # has_many yslists : Yslist, foreign_key: "ysuser_id"
  # has_many yscrits : Yscrit, foreign_key: "ysuser_id"
  # has_many nvinfos : Nvinfo, through: "yscrits"

  column zname : String
  column vname : String
  column vslug : String = ""

  column like_count : Int32 = 0
  column star_count : Int32 = 0

  column list_total : Int32 = 0
  column list_count : Int32 = 0

  column crit_total : Int32 = 0
  column crit_count : Int32 = 0

  column stime : Int64 = 0

  timestamps

  def fix_name : Nil
    self.vname = SP::MtCore.tl_name(self.zname)
    self.vslug = TextUtil.slugify(vname)
  end

  ###############

  def self.upsert!(zname : String, origin_id : Int32)
    find({zname: zname}) || begin
      entry = new({origin_id: origin_id, zname: zname}).tap(&.fix_name)
      entry.tap(&.save!)
    end
  end

  def self.preload(ids : Enumerable(Int32))
    ids.empty? ? [] of self : query.where { id.in? ids }
  end
end

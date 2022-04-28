class CV::Ysuser
  include Clear::Model

  self.table = "ysusers"
  primary_key

  # has_many yslists : Yslist, foreign_key: "ysuser_id"
  # has_many yscrits : Yscrit, foreign_key: "ysuser_id"
  # has_many nvinfos : Nvinfo, through: "yscrits"

  column zname : String
  column vname : String
  column vslug : String = ""

  column like_count : Int32 = 0 # TBD: total list like_count or direct like count
  column list_count : Int32 = 0 # book list count
  column crit_count : Int32 = 0 # review count

  timestamps

  def fix_name : Nil
    self.vname = BookUtil.hanviet(self.zname, caps: true)
    self.vslug = BookUtil.scrub_vname(self.vname, "-")
  end

  ###############

  def self.upsert!(zname : String)
    find({zname: zname}) || begin
      entry = new({zname: zname}).tap(&.fix_name)
      entry.tap(&.save!)
    end
  end
end

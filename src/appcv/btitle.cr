require "./shared/book_util"

# storing book names

class CV::Btitle
  include Clear::Model

  self.table = "btitles"
  primary_key

  column zname : String = "" # chinese title
  column hname : String = "" # hanviet title
  column vname : String = "" # localization

  column hslug : String = "" # for text searching, auto generated from hname
  column vslug : String = "" # for text searching, auto generated from vname

  timestamps # created_at and updated_at

  def regen!(bdict : String = "combine") : Nil
    self.set_hname(BookUtil.hanviet(self.zname))
    self.set_vname(BookUtil.btitle_vname(self.zname, bdict))

    self.save!
  end

  def set_hname(hname : String) : Nil
    self.hname = hname
    self.hslug = BookUtil.make_slug(hname)
  end

  def set_vname(vname : String) : Nil
    self.vname = vname
    self.vslug = BookUtil.make_slug(vname)
  end

  #########################################

  def self.upsert!(zname : String, bdict : String = "combine") : self
    find({zname: zname}) || new({zname: zname}).tap(&.regen!(bdict))
  end
end

require "./shared/book_util"
require "./_base"

# storing book names

class CV::Btitle
  include Clear::Model

  self.table = "btitles"
  primary_key type: :serial

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

  def self.upsert!(zname : String, vname : String? = nil, bdict : String = "combine") : self
    unless btitle = find({zname: zname})
      btitle = new({zname: zname})

      btitle.set_vname(vname || BookUtil.btitle_vname(zname, bdict))
      btitle.set_hname(BookUtil.hanviet(zname))

      return btitle.tap(&.save!)
    end

    btitle.tap(&.set_vname(vname)).save! if vname && vname != btitle.vname
    btitle
  end
end

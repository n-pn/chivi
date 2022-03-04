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

  def set_hname(hname : String = gen_hname) : self
    self.hname = hname
    self.hslug = BookUtil.make_slug(hname)
    self
  end

  def set_vname(vname : String = gen_vname) : self
    self.vname = vname
    self.vslug = BookUtil.make_slug(vname)
    self
  end

  def gen_hname
    BookUtil.hanviet(self.zname)
  end

  def gen_vname(bdict : String = "combine") : self
    vname = BookUtil.vi_btitles.fval(self.zname) || gen_vname_mtl(dict)
    TextUtil.titleize(vname)
  end

  def gen_vname_mtl(bdict : String)
    mtl = MtCore.generic_mtl(bhash)
    txt = self.zname

    PREFIXES.each do |key, val|
      next unless txt.starts_with?(key)
      return val + mtl.translate(txt[key.size..])
    end

    mtl.translate(txt)
  end

  PREFIXES = {
    "火影之" => "NARUTO: ",
    "民国之" => "Dân quốc: ",
    "三国之" => "Tam Quốc: ",
    "综漫之" => "Tổng mạn: ",
    "娱乐之" => "Giải trí: ",
    "重生之" => "Trùng sinh: ",
    "穿越之" => "Xuyên qua: ",
    "复活之" => "Phục sinh: ",
    "网游之" => "Game online: ",

    "哈利波特之" => "Harry Potter: ",
    "网游三国之" => "Tam Quốc game online: ",
  }

  #########################################

  def self.upsert!(zname : String) : Author
    find({zname: zname}) || begin
      new({zname: zname}).set_hname.set_vname.save!
    end
  end
end

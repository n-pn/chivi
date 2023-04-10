require "../../mtapp/sp_core"

require "../_base"

# storing book names

class CV::Btitle
  include Clear::Model

  self.table = "btitles"
  primary_key type: :serial

  column zname : String = "" # chinese title
  column hname : String = "" # hanviet title
  column vname : String = "" # localization

  # column hslug : String = "" # for text searching, auto generated from hname
  # column vslug : String = "" # for text searching, auto generated from vname

  timestamps # created_at and updated_at

  def self.upsert!(zname : String, vname : String?) : self
    if entry = find({zname: zname})
      if vname && vname != entry.vname
        entry.update({vname: vname})
      end

      entry
    else
      entry = new({zname: zname})

      entry.hname = MT::SpCore.tl_hvname(zname)
      entry.vname = vname || entry.hname

      entry.tap(&.save!)
    end
  end
end

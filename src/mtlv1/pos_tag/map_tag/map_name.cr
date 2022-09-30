require "../mtl_pos"
require "../mtl_tag"

struct CV::PosTag
  def self.map_name(tag : String)
    case tag[1]?
    when 'r' then self.human_name
    when 'a' then self.affil_name
    when 'l' then new(:x_brand, MtlPos.flags(Proper))
    when 'w' then new(:x_title, MtlPos.flags(Proper, Ktetic))
    else          new(:x_other, MtlPos.flags(Proper, Ktetic))
    end
  end

  def self.human_name(tag : MtlTag = :human0)
    new(tag, MtlPos.flags(Proper, People, Ktetic))
  end

  def self.affil_name(tag : MtlTag = :affil0)
    new(tag, MtlPos.flags(Proper, Places, Ktetic))
  end
end

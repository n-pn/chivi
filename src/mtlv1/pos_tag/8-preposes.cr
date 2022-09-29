struct CV::PosTag
  # 介词 - preposition - giới từ
  POSPRE = Pos::Preposes

  PreBa3 = new(Tag::PreBa3, POSPRE)
  PreBei = new(Tag::PreBei, POSPRE)
  PreDui = new(Tag::PreDui, POSPRE)
  PreZai = new(Tag::PreZai, POSPRE)
  PreBi3 = new(Tag::PreBi3, POSPRE)
  Prepos = new(Tag::Prepos, POSPRE)

  def self.parse_prepos(key : ::String)
    case key
    when "把"  then PreBa3
    when "被"  then PreBei
    when "对"  then PreDui
    when "在"  then PreZai
    when "比"  then PreBi3
    when "不比" then PreBi3
    else           Prepos
    end
  end
end

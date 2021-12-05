struct CV::PosTag
  # 介词 - preposition - giới từ
  POSPRE = Pos::Preposes | Pos::Funcws

  PrepBa = new(Tag::PreBa, POSPRE)
  PreBei = new(Tag::PreBei, POSPRE)
  PreDui = new(Tag::PreDui, POSPRE)
  PreZai = new(Tag::PreZai, POSPRE)
  Prepos = new(Tag::Prepos, POSPRE)

  def self.map_preposes(key : ::String)
    case key
    when "把" then PrepBa
    when "被" then PreBei
    when "对" then PreDui
    when "在" then PreZai
    else          Prepos
    end
  end
end

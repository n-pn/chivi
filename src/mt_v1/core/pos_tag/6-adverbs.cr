struct M1::PosTag
  # 副词 - adverb - phó từ (trạng từ)

  AdvNoun = new(Tag::AdvNoun, Pos::Polysemy | Pos::Nominal | Pos::Adverbial)
  AdvUniq = new(Tag::AdvUniq, Pos::Polysemy | Pos::Nominal | Pos::Adverbial)

  Adverb = new(Tag::Adverb, Pos::Adverbial)
  AdvBu4 = new(Tag::AdvBu4, Pos::Adverbial)
  AdvFei = new(Tag::AdvFei, Pos::Adverbial)
  AdvMei = new(Tag::AdvMei, Pos::Adverbial)

  def self.parse_adverb(key : String)
    case key
    when "不" then AdvBu4
    when "没" then AdvMei
    when "非" then AdvFei
    else          Adverb
    end
  end
end

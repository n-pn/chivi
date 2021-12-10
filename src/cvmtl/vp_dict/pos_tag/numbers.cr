struct CV::PosTag
  # 数词 - numeral - số từ
  NB_POS = Pos::Numbers | Pos::Numeric | Pos::Contws
  Ndigit = new(Tag::Ndigit, NB_POS)
  Nhanzi = new(Tag::Nhanzi, NB_POS)
  Number = new(Tag::Number, NB_POS)

  # # 量词 - quantifier - lượng từ
  QT_POS = Pos::Quantis | Pos::Numeric | Pos::Contws
  Qtnoun = new(Tag::Qtnoun, QT_POS | Pos::Nouns)
  Qttime = new(Tag::Qttime, QT_POS | Pos::Nouns | Pos::Times)
  Qtverb = new(Tag::Qtverb, QT_POS)

  # 数量词 - numeral and quantifier - số lượng từ
  NQ_POS = Pos::Nquants | Pos::Numeric | Pos::Contws
  Nqnoun = new(Tag::Nqnoun, NQ_POS | Pos::Nouns)
  Nqtime = new(Tag::Nqtime, NQ_POS | Pos::Nouns | Pos::Times)
  Nqverb = new(Tag::Nqverb, NQ_POS)
  Nqiffy = new(Tag::Nqiffy, NQ_POS) # unknown nquants

  NUMLAT_RE = /^\d+$/
  NUMHAN_RE = /^[零〇一二两三四五六七八九十百千万亿兆]+$/

  def self.map_numbers(key : ::String) : self
    case key
    when .matches?(NUMLAT_RE) then Ndigit
    when .matches?(NUMHAN_RE) then Nhanzi
    else                           Number
    end
  end

  def self.map_quantis(key : ::String) : self
    return Qttime if MtDict::QUANTI_TIMES.has_key?(key)
    return Qtverb if MtDict::QUANTI_VERBS.has_key?(key)
    Qtnoun
  end

  NUMCHR_RE = /[零〇一二两三四五六七八九十百千万亿兆多每]/

  def self.map_nquants(key : ::String) : self
    key = key.sub(NUMCHR_RE, "")
    case
    when MtDict::QUANTI_TIMES.has_key?(key) then Nqtime
    when MtDict::QUANTI_NOUNS.has_key?(key) then Nqnoun
    when MtDict::QUANTI_VERBS.has_key?(key) then Nqverb
    else                                         Nqiffy
    end
  end
end

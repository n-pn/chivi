require "../mt_dict"

struct MtlV2::PosTag
  # 数词 - numeral - số từ
  NB_POS = Pos::Numbers | Pos::Numeral | Pos::Contws
  Ndigit = new(Tag::Ndigit, NB_POS)
  Nhanzi = new(Tag::Nhanzi, NB_POS)
  Number = new(Tag::Number, NB_POS)

  # # 量词 - quantifier - lượng từ
  QT_POS = Pos::Quantis | Pos::Numeral | Pos::Contws
  Qtnoun = new(Tag::Qtnoun, QT_POS | Pos::Nominal)
  Qttime = new(Tag::Qttime, QT_POS | Pos::Nominal)
  Qtverb = new(Tag::Qtverb, QT_POS)

  # 数量词 - numeral and quantifier - số lượng từ
  NQ_POS = Pos::Nquants | Pos::Numeral | Pos::Contws
  Nqnoun = new(Tag::Nqnoun, NQ_POS | Pos::Nominal)
  Nqtime = new(Tag::Nqtime, NQ_POS | Pos::Nominal)
  Nqverb = new(Tag::Nqverb, NQ_POS)
  Nqiffy = new(Tag::Nqiffy, NQ_POS) # unknown nquants

  NUMLAT_RE = /^[0-9０-９]+$/
  NUMHAN_RE = /^[零〇一二两三四五六七八九十百千万亿兆]+$/

  def self.parse_number(tag : String, key : String) : self
    return parse_nquant(key) if tag == "mq"

    case key
    when .matches?(NUMLAT_RE) then Ndigit
    when .matches?(NUMHAN_RE) then Nhanzi
    else                           Number
    end
  end

  def self.parse_quanti(key : String) : self
    return Qttime if MtDict.qt_times.has_key?(key)
    return Qtverb if MtDict.qt_verbs.has_key?(key)
    Qtnoun
  end

  NUMCHR_RE = /[零〇一二两三四五六七八九十百千万亿兆多每]/

  def self.parse_nquant(key : ::String) : self
    key = key.sub(NUMCHR_RE, "")
    case
    when MtDict.qt_times.has_key?(key) then Nqtime
    when MtDict.qt_nouns.has_key?(key) then Nqnoun
    when MtDict.qt_verbs.has_key?(key) then Nqverb
    else                                    Nqiffy
    end
  end
end
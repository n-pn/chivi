module MT::MapTag
  Ordinal = make(:ordinal)
  Numeric = make(:numeric)

  Ndigit1 = make(:ndigit1)
  Ndigit2 = make(:ndigit2)

  Nhanzi0 = make(:nhanzi0)
  Nhanzi1 = make(:nhanzi1)
  Nhanzi2 = make(:nhanzi2)

  NUMBER_MAP = load_map("nquants")

  def self.map_number(tag : String, key : String) : {MtlTag, MtlPos}
    return map_nquant(key) if tag[1]? == 'q'

    NUMBER_MAP[key] ||= begin
      case key
      when .starts_with?('第')
        Ordinal
      when .matches?(/\d/)
        key.matches?(/\D/) ? Ndigit2 : Ndigit1
      when .matches?(/[零〇一二两三四五六七八九十百千万亿兆]/)
        Nhanzi0
      else
        Numeric
      end
    end
  end

  NQUANT_MAP = load_map("nquants")

  Nqnoun = make(:nqnoun, :nounish)
  Nqtime = make(:nqtime, :nounish)

  def self.map_nquant(key : String)
    NQUANT_MAP[key] ||= begin
      tag, pos = map_quanti(clean_nquant(key))
      {tag + 20, pos}
    end
  end

  NUM_CHARS = {
    '零', '一', '二', '三', '四', '五', '六', '七', '八', '九', '十',
    '两', '百', '千', '万', '亿', '兆',
  }

  def self.clean_nquant(key : String) : String
    chars = key.chars
    index = 0
    index += 1 if chars.unsafe_fetch(0).in?('第', '每')

    upper = chars.size &- 1
    upper &-= 1 if chars.unsafe_fetch(upper).in?('多', '来', '余', '几')

    while index <= upper
      char = chars.unsafe_fetch(index)
      break unless NUM_CHARS.includes?(char)
      index += 1
    end

    return "" if index > upper

    index &+= 1 if chars.unsafe_fetch(index).in?('多', '来', '余', '几')
    chars[index..upper].join
  end

  QUANTI_MAP = load_map("quantis")

  def self.map_quanti(key : String)
    QUANTI_MAP[key] ||= make(:qtnoun)
  end
end

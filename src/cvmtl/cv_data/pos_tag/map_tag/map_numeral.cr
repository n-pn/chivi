struct MT::PosTag
  NUMBER_MAP = load_map("map_number", MtlPos.flags(Object))

  def self.map_number(tag : String, key : String) : self
    return map_nquant(key) if tag[1]? == 'q'

    NUMBER_MAP[key] ||= begin
      case key
      when .starts_with?('第') then new(:ordinal)
      when .matches?(/\d/)
        key.matches?(/\D/) ? new(:ndigit2) : new(:ndigit1)
      when .matches?(/[零〇一二两三四五六七八九十百千万亿兆]/)
        new(:nhanzi0)
      else
        new(:numeric)
      end
    end
  end

  NQUANT_MAP = load_map("map_nquant", :object)

  def self.map_nquant(key : String)
    NQUANT_MAP[key] ||= begin
      res = map_quanti(clean_nquant(key))
      res.tag = res.tag.qt_to_nq
      res
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

  QUANTI_MAP = load_map("map_quanti")

  def self.map_quanti(key : String)
    QUANTI_MAP[key]? || new(:qtnoun)
  end
end

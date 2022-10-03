struct CV::PosTag
  Ordinal = new(:ordinal)
  Numeric = new(:numeric)

  Ndigit1 = new(:ndigit1)
  Ndigit2 = new(:ndigit2)

  Nhanzi0 = new(:nhanzi0)
  Nhanzi1 = new(:nhanzi1)
  Nhanzi2 = new(:nhanzi2)

  def self.map_number(tag : String, key : String) : self
    return map_nquant(key) if tag[1]? == 'q'

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

  def self.map_nquant(key : String)
    new(:nqnoun)
  end

  def self.map_quanti(key : String)
    new(:qtnoun)
  end
end

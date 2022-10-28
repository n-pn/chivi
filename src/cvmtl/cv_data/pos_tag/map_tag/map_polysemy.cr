module MT::PosTag
  QTTEMP_MAP = load_map("map_qttemp")
  NQTEMP_MAP = load_map("map_nqtemp")

  def self.map_polysemy(tag : String, key = "")
    case tag
    when "~vn" then make(:verb_or_noun)
    when "~an" then make(:adjt_or_noun)
    when "~vd" then make(:verb_or_advb)
    when "~ad" then make(:adjt_or_advb)
    when "~nd" then make(:noun_or_advb)
    when "~qt" then QTTEMP_MAP[key]? || make(:quanti_or_x)
    when "~nq" then NQTEMP_MAP[key]? || make(:nquant_or_x)
    else            make(:lit_blank)
    end
  end
end

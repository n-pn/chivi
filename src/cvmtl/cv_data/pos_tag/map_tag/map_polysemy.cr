module MT::PosTag
  def self.map_polysemy(tag : String, key = "")
    case tag
    when "~vn" then make(:verb_or_noun)
    when "~an" then make(:adjt_or_noun)
    when "~vd" then make(:verb_or_advb)
    when "~ad" then make(:adjt_or_advb)
    when "~nd" then make(:noun_or_advb)
    else            make(:lit_blank)
    end
  end
end

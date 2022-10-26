struct MT::PosTag
  def self.map_polysemy(tag : String, key = "")
    case tag
    when "~vn" then new(:verb_or_nnoun)
    when "~an" then new(:adjt_or_nnoun)
    when "~vd" then new(:verb_or_advb)
    when "~ad" then new(:adjt_or_advb)
    when "~nd" then new(:noun_or_advb)
    else            new(:lit_blank)
    end
  end
end

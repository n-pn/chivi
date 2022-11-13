module MT::PosTag
  def self.map_phrase(tag : String)
    case tag
    when "Psv" then MtlTag::SubjVerb
    when "Psa" then MtlTag::SubjAdjt
    when "Ppn" then MtlTag::PrepForm
    when "Pdp" then MtlTag::DpPhrase
    when "Pdc" then MtlTag::DcPhrase
    when "Pdg" then MtlTag::DgPhrase
    when "Pdr" then MtlTag::DrPhrase
    when "Pdv" then MtlTag::DvPhrase
    when "Ppe" then MtlTag::ParenExp
    else            MtlTag::LitTrans
    end
  end
end

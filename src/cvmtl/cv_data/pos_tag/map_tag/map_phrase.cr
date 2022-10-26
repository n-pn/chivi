struct MT::PosTag
  def self.map_phrase(tag : String) : self
    case tag
    when "+sv" then new(MtlTag::SubjVerb)
    when "+sa" then new(MtlTag::SubjAdjt)
    when "+pp" then new(MtlTag::PrepForm)
    when "+dp" then new(MtlTag::DpPhrase)
    when "+dc" then new(MtlTag::DcPhrase)
    when "+dg" then new(MtlTag::DgPhrase)
    when "+dr" then new(MtlTag::DrPhrase)
    when "+dv" then new(MtlTag::DvPhrase)
    when "+pe" then new(MtlTag::ParenExp)
    else            new(MtlTag::LitTrans)
    end
  end
end

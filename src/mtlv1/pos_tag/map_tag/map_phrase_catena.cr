struct CV::PosTag
  SubjVerb = new(:subj_verb, MtlPos.flags(Advbial, Adjtish))
  SubjAdjt = new(:subj_adjt, MtlPos.flags(Advbial, Adjtish))
  PrepForm = new(:prep_form, MtlPos.flags(Advbial, AtHead))

  DcPhrase = new(:dc_phrase, MtlPos.flags(Advbial, Adjtish))
  DgPhrase = new(:dg_phrase, MtlPos.flags(Advbial, Adjtish))
  DrPhrase = new(:dr_phrase, MtlPos.flags(Advbial, AtHead))
  DvPhrase = new(:dv_phrase, MtlPos.flags(Vcompl, AtTail))

  def self.map_phrase(tag : String) : self
    case tag
    when "+sv" then SubjVerb
    when "+sa" then SubjAdjt
    when "+pp" then PrepForm
    when "+dc" then DcPhrase
    when "+dg" then DgPhrase
    when "+dr" then DrPhrase
    when "+dv" then DvPhrase
    else            LitTrans
    end
  end
end

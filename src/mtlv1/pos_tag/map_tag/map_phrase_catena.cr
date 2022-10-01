struct CV::PosTag
  SubjVerb = new(:subj_verb, pos(ModSub, Adjtish))
  SubjAdjt = new(:subj_adjt, pos(ModSub, Adjtish))
  PrepForm = new(:prep_form, pos(ModSub, AdvPre))

  DcPhrase = new(:dc_phrase, pos(ModSub, Adjtish))
  DgPhrase = new(:dg_phrase, pos(ModSub, Adjtish))
  DrPhrase = new(:dr_phrase, pos(AdvPre))
  DvPhrase = new(:dv_phrase, pos(Vcompl))

  def self.parse_phrase(tag : String) : self
    case tag
    when "+sv" then SubjVerb
    when "+sa" then SubjAdjt
    when "+pp" then PrepForm
    when "+dc" then DcPhrase
    when "+dg" then DgPhrase
    when "+dr" then DrPhrase
    when "+dv" then DvPhrase #
    else            LitTrans
    end
  end
end

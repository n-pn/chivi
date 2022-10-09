struct CV::PosTag
  SubjVerb = new(:subj_verb, MtlPos.flags(MaybeAdvb, MaybeAdjt))
  SubjAdjt = new(:subj_adjt, MtlPos.flags(MaybeAdvb, MaybeAdjt))
  PrepForm = new(:prep_form, MtlPos.flags(MaybeAdvb, AtHead))

  DpPhrase = new(:dp_phrase, MtlPos.flags(MaybeAdvb, MaybeAdjt))
  DcPhrase = new(:dc_phrase, MtlPos.flags(MaybeAdvb, MaybeAdjt))
  DgPhrase = new(:dg_phrase, MtlPos.flags(MaybeAdvb, MaybeAdjt))
  DrPhrase = new(:dr_phrase, MtlPos.flags(MaybeAdvb, AtHead))
  DvPhrase = new(:dv_phrase, MtlPos.flags(Vcompl, AtTail))

  ParenExp = new(:paren_exp, :none)

  def self.map_phrase(tag : String) : self
    case tag
    when "+sv"  then SubjVerb
    when "+sa"  then SubjAdjt
    when "+pp"  then PrepForm
    when "+dp"  then DpPhrase
    when "+dc"  then DcPhrase
    when "+dg"  then DgPhrase
    when "+dr"  then DrPhrase
    when "+dv"  then DvPhrase
    when "+par" then ParenExp
    else             LitTrans
    end
  end
end

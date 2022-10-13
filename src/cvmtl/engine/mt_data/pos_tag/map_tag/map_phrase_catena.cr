module MT::MapTag
  SubjVerb = make(:subj_verb, MtlPos.flags(MaybeAdvb, MaybeAdjt))
  SubjAdjt = make(:subj_adjt, MtlPos.flags(MaybeAdvb, MaybeAdjt))
  PrepForm = make(:prep_form, MtlPos.flags(MaybeAdvb, AtHead))

  DpPhrase = make(:dp_phrase, MtlPos.flags(MaybeAdvb, MaybeAdjt))
  DcPhrase = make(:dc_phrase, MtlPos.flags(MaybeAdvb, MaybeAdjt))
  DgPhrase = make(:dg_phrase, MtlPos.flags(MaybeAdvb, MaybeAdjt))
  DrPhrase = make(:dr_phrase, MtlPos.flags(MaybeAdvb, AtHead))
  DvPhrase = make(:dv_phrase, MtlPos.flags(Vcompl, AtTail))

  ParenExp = make(:paren_exp, :none)

  def self.map_phrase(tag : String) : {MtlTag, MtlPos}
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

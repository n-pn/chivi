module M1::TlRule
  def fold_adjt_ude2!(adjt : MtNode, ude2 : MtNode)
    return adjt if adjt.prev?(&.noun?)
    return adjt unless (succ = ude2.succ?) && succ.verbal?

    adjt = fold!(adjt, ude2.set!("mà"), PosTag::Adverb, dic: 3)
    fold!(adjt, fold_verbs!(succ), PosTag::VerbPhrase, dic: 5)
  end
end

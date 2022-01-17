module CV::TlRule
  def fold_adjt_ude2!(adjt : MtNode, ude2 : MtNode)
    return adjt if adjt.prev?(&.noun?)
    return adjt unless (succ = ude2.succ?) && succ.verbs?

    adjt = fold!(adjt, ude2.set!("mà"), PosTag::Adverb, dic: 3)
    return fold!(adjt, fold_verbs!(succ), PosTag::VerbPhrase, dic: 5)
  end
end

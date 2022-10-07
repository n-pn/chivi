module CV::TlRule
  def fold_adjt_ude2!(adjt : BaseNode, ude2 : BaseNode)
    return adjt if adjt.prev?(&.common_nouns?)
    return adjt unless (succ = ude2.succ?) && succ.verb_words?

    adjt = fold!(adjt, ude2.set!("mà"), PosTag::DrPhrase, dic: 3)
    fold!(adjt, fold_verbs!(succ), PosTag::Vform, dic: 5)
  end
end

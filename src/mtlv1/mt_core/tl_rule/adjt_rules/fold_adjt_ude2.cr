module CV::TlRule
  def fold_adjt_ude2!(adjt : MtNode, ude2 : MtNode)
    return adjt if adjt.prev?(&.nouns?)
    return adjt unless (succ = ude2.succ?) && succ.verbal?

    adjt = fold!(adjt, ude2.set!("mà"), PosTag::DrPhrase, dic: 3)
    fold!(adjt, fold_verbs!(succ), PosTag::Vform, dic: 5)
  end
end

module M1::TlRule
  def fold_verb_uzhe!(prev : MtNode, uzhe : MtNode, succ = uzhe.succ?) : MtNode
    uzhe.val = ""

    if succ && succ.maybe_verb?
      succ = succ.adverbial? ? fold_adverbs!(succ) : fold_verbs!(succ)
      fold!(prev, succ, succ.tag, dic: 3)
    else
      fold!(prev, uzhe, prev.tag, dic: 3)
    end
  end
end

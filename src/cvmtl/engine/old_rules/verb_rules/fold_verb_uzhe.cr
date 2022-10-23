module MT::TlRule
  def fold_verb_uzhe!(prev : MtNode, uzhe : MtNode, succ = uzhe.succ?) : MtNode
    uzhe.val = ""

    if succ && succ.maybe_verb?
      succ = succ.advb_words? ? fold_adverbs!(succ) : fold_verbs!(succ)
      fold!(prev, succ, succ.tag)
    else
      fold!(prev, uzhe, prev.tag)
    end
  end
end

module MT::TlRule
  def fold_verb_uzhe!(prev : BaseNode, uzhe : BaseNode, succ = uzhe.succ?) : BaseNode
    uzhe.val = ""

    if succ && succ.maybe_verb?
      succ = succ.advb_words? ? fold_adverbs!(succ) : fold_verbs!(succ)
      fold!(prev, succ, succ.tag)
    else
      fold!(prev, uzhe, prev.tag)
    end
  end
end

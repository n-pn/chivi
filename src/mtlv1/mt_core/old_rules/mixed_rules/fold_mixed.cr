module CV::TlRule
  def fold_mixed!(node, prev = node.prev?, succ = node.succ?)
    node = heal_mixed!(node, prev, succ)

    case node.tag
    when .adjt_words? then fold_adjts!(node)
    when .noun_words? then fold_nouns!(node)
    when .verb_words?     then fold_verbs!(node)
    when .advb_words?    then fold_adverbs!(node)
    else                   node
    end
  end
end

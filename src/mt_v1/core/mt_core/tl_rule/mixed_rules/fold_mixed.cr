module M1::TlRule
  def fold_mixed!(node, prev = node.prev?, succ = node.succ?)
    node = heal_mixed!(node, prev, succ)

    case node.tag
    when .adjective? then fold_adjts!(node)
    when .nominal?   then fold_nouns!(node)
    when .verbal?    then fold_verbs!(node)
    when .adverbial? then fold_adverbs!(node)
    else                  node
    end
  end
end

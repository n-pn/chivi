module CV::TlRule
  def fold_ajad!(node : MtNode, succ = node.succ?)
    return node unless succ
    case succ
    when .adjts?, .verbs?
      node.tag = PosTag::Adverb
      fold_adverbs!(node)
    else
      node.tag = PosTag::Adjt
      fold_adjts!(node)
    end
  end
end

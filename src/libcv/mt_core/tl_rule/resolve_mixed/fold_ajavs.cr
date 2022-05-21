module CV::TlRule
  def fold_ajad!(node : MtNode, succ = node.succ?)
    return node unless succ
    case succ
    when .adjective?, .verbal?
      node.tag = PosTag::Adverb
      fold_adverbs!(node)
    else
      fold_adjts!(MtDict.fix_adjt!(node))
    end
  end
end

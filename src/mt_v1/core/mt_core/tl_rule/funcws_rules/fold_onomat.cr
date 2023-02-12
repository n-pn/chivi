module M1::TlRule
  def fold_onomat!(node : MtNode, succ = node.succ?)
    case succ
    when .nil?    then node
    when .verbal? then fold_verbs!(succ, prev: node)
    when .ude1?
      succ.set!("mà")
      return node unless (succ_2 = succ.succ?) && succ_2.verbal?
      succ_2 = fold_verbs!(succ_2)
      fold!(node, succ_2, succ_2.tag, dic: 5)
    else
      node
    end
  end
end

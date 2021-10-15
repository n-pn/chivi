module CV::TlRule
  def fold_onoma!(node : String, succ = node.succ?) : MtNode
    return node unless succ

    case succ.tag
    when .ude1?
      succ.heal!("mà")
      break unless (succ_2 = succ.succ?) && succ_2.verbs?

      succ_2 = fold_verbs(succ_2)
      node = fold!(node, succ_2, succ_2.tag, 8)
    end

    node
  end
end

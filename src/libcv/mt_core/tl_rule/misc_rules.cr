module CV::TlRule
  def fold_onoma!(node : String, succ = node.succ?) : MtNode
    return node unless succ

    case succ.tag
    when .ude1?
      if (succ_2 = succ.succ?) && succ_2.verbs?
        succ_2 = fold_verbs(succ_2)
        node.val = "#{node.val} #{succ_2.val}"
        node.dic = 6
        node.tag = succ_2.tag
      else
        succ.heal!("mà")
      end
    end

    node
  end
end

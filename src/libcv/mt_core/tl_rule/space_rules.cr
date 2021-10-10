module CV::TlRule
  def fold_noun_space!(node : MtNode, succ = node.succ?) : MtNode
    return node unless succ
    node.tag = PosTag::Place

    # if (prev = node.prev?) && prev.nquant?
    #   prev.val = "#{succ.val} #{prev.val} #{node.val}"
    #   prev.dic = 7
    #   node = prev.fold_many!(node, succ)
    # else

    case succ.key
    when "上"
      node.fold!("trên #{node.val}")
    when "下"
      node.fold!("dưới #{node.val}")
    when "之前"
      node.fold!("trước #{node.val}")
    else
      node.fold!("#{succ.val} #{node.val}")
    end
  end
end

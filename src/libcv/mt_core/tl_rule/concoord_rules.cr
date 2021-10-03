module CV::TlRule
  extend self

  def fold_near_concoord!(prev : MtNode, node : MtNode = prev.succ, succ = node.succ?) : MtNode
    return prev unless succ
    return prev unless prev.tag == succ.tag

    prev.key = "#{prev.key}#{node.key}#{succ.key}"
    prev.val = "#{prev.val} #{node.val} #{succ.val}"
    prev.dic = 6

    prev.fix_succ!(succ.succ)
  end
end

module CV::TlRule
  extend self

  def fold_concoord!(prev : MtNode, node = prev.succ, succ = node.succ?, force = false) : MtNode
    return prev unless succ && (force || prev.tag == succ.tag)

    val = node.key == "和" ? "và" : node.val
    prev.key = "#{prev.key}#{node.key}#{succ.key}"
    prev.val = "#{prev.val} #{val} #{succ.val}"
    prev.dic = 6

    prev.fix_succ!(succ.succ)
  end
end

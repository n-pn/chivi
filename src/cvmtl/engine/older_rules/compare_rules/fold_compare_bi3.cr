module MT::TlRule
  def fold_compare_bi3_after!(node : MtNode, last : MtNode)
    return node unless (succ = node.succ?) && succ.particles? && (tail = succ.succ?)

    case succ
    when .ptcl_le?
      return node unless tail.key == "点"
      last.fix_succ!(succ.set!(""))
      node.fix_succ!(tail.succ?)
      tail.fix_succ!(nil)
      node.set!(PosTag.make(:amix))
    when .ptcl_dep?, .ptcl_der?
      return node unless tail.key == "多"
      last.fix_succ!(succ.set!(""))
      node.fix_succ!(tail.succ?)
      tail.fix_succ!(nil)
      node
    else
      node
    end
  end
end

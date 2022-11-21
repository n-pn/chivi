module MT::TlRule
  def fold_noun_cenum!(head : MtNode, join : MtNode)
    while node = join.succ?
      break unless node.all_nouns? || node.all_prons?
      tail = node

      break unless join = node.succ?

      if join.ptcl_dep?
        break unless (succ = join.succ?) && succ.all_nouns?
        join.val = "của"
        node = fold!(node, succ, succ.tag, flip: true)
        break unless join = node.succ?
      end

      break unless join.cenum?
    end

    tail ? fold!(head, tail, MapTag::Nform) : head
  end
end

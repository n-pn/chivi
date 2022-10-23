module MT::TlRule
  def fold_noun_cenum!(head : MtNode, join : MtNode)
    while node = join.succ?
      break unless node.noun_words? || node.pronouns?
      tail = node

      break unless join = node.succ?

      if join.pt_dep?
        break unless (succ = join.succ?) && succ.noun_words?
        join.val = "của"
        node = fold!(node, succ, succ.tag, flip: true)
        break unless join = node.succ?
      end

      break unless join.cenum?
    end

    tail ? fold!(head, tail, MapTag::Nform) : head
  end
end

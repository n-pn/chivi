module M1::TlRule
  def fold_noun_penum!(head : MtNode, join : MtNode)
    while node = join.succ?
      break unless node.nominal? || node.pronouns?
      tail = node

      break unless join = node.succ?

      if join.ude1?
        break unless (succ = join.succ?) && succ.nominal?
        join.val = "của"
        node = fold!(node, succ, succ.tag, dic: 7, flip: true)
        break unless join = node.succ?
      end

      break unless join.penum?
    end

    tail ? fold!(head, tail, PosTag::NounPhrase, dic: 8) : head
  end
end

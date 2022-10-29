module MT::Rules
  def link_verb!(verb : MtNode, prev = verb.prev)
    return link_verb_bond!(verb, prev) if prev.bind_word?
    verb
  end

  def link_verb_bond!(verb, bond, head = bond.prev)
    case head
    when .common_verbs?
      head = fold_verb_cons!(head)
    when .noun_words?
      head = fold_noun!(head)
    else
      return verb
    end

    tag = MtlTag::Vmix
    pos = head.pos | verb.pos

    TrioNode.new(head, bond, verb, tag: tag, pos: pos)
  end
end

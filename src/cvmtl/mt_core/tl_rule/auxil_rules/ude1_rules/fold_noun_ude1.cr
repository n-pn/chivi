module CV::TlRule
  def fold_noun_ude1!(noun : MtNode, ude1 : MtNode, right : MtNode) : MtNode
    # puts [noun, ude1, right]

    if (prev = noun.prev?) && prev.verbs?
      fold_verb_noun_ude1!(prev, noun, ude1, right)
    else
      fold_noun_ude1_noun!(noun, ude1, right)
    end
  end

  def fold_noun_ude1_noun!(noun : MtNode, ude1 : MtNode, right : MtNode) : MtNode
    ude1.val = "của"
    noun = fold_swap!(noun, ude1, PosTag::DefnPhrase, dic: 2)

    dic = noun.prev?(&.verbs?) ? 6 : 4
    fold_swap!(noun, right, PosTag::NounPhrase, dic: dic)
  end

  def fold_verb_noun_ude1!(verb : MtNode, noun : MtNode, ude1 : MtNode, right : MtNode) : MtNode
    case right.key
    when "时候", "时"
      head = verb.try { |x| x if x.center_noun? } || verb
      node = fold!(head, ude1, PosTag::DefnPhrase)
      return fold_swap!(node, right, PosTag::NounPhrase, dic: 6)
    end

    # puts [verb, noun, ude1, right]

    case prev = verb.prev?
    when .nil?, .none?
      head = verb if tail = find_verb_after(right)
    when .v_you?
      head = prev.center_noun? ? prev : verb
    when .v_shi?
      head = verb unless find_verb_after(right)
    else
      unless is_linking_verb?(prev, right.succ?)
        head = verb if find_verb_after(right)
      end
    end

    return fold_noun_ude1_noun!(noun, ude1, right) unless head

    node = fold!(head, ude1, PosTag::DefnPhrase)
    fold_swap!(node, right, PosTag::NounPhrase, dic: 6)
  end
end

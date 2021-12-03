module CV::TlRule
  def fold_noun_ude1!(noun : MtNode, ude1 : MtNode, right : MtNode) : MtNode
    if (prev = noun.prev?) && is_verb_clause?(prev, right)
      prev = fold!(prev, ude1, PosTag::DefnPhrase, dic: 9)
      return fold_swap!(prev, right, PosTag::NounPhrase, dic: 6)
    end

    ude1.val = "của"
    noun = fold_swap!(noun, ude1, PosTag::DefnPhrase, dic: 2)

    puts [noun, ude1, right]

    dic = noun.prev?(&.verbs?) ? 6 : 4
    fold_swap!(noun, right, PosTag::NounPhrase, dic: dic)
  end

  def is_verb_clause?(head : MtNode, tail : MtNode)
    if head.v_you?
      # TODO: check more conditions
      return false
    end

    return false unless head.verb? || head.verb_phrase?

    by_succ = check_vclause_by_succ?(tail.succ?)
    return by_succ == 2 unless prev = head.prev?

    case prev.tag
    when .v_shi?, .verb?, .numeric?, .pro_dems?
      true
    when .nouns?, .comma?, .pro_per?, .popens?
      false
    else
      prev.key == "在" ? true : by_succ > 1
    end
  end

  # 0 : not a clause, 1: decide by prev values, 2: is a clause!
  def check_vclause_by_succ?(succ : MtNode?)
    return 1 unless succ
    return 2 if succ.v_shi? || succ.v_you? || succ.vmodals?
    return 1 if succ.verbs? || succ.adverbs? || succ.preposes?

    # TODO: check more here
    return 0 if succ.comma?
    succ.ends? ? 1 : 0
  end
end

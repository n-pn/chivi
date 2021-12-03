module CV::TlRule
  def fold_noun_ude1!(noun : MtNode, ude1 : MtNode, right : MtNode) : MtNode
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

  def find_verb_after(right : MtNode)
    while right = right.succ?
      # puts ["find_verb", right]
      return right if right.verbs?
      return nil unless right.adverbs? || right.comma? # || right.conjunct?
    end
  end

  # def is_verb_clause?(head : MtNode, tail : MtNode)
  #   return false unless head.verb? || head.verb_phrase?

  #   by_succ = check_vclause_by_succ?(tail.succ?)
  #   return by_succ == 2 unless prev = head.prev?

  #   case prev.tag
  #   when .v_shi?, .verb?, .numeric?, .pro_dems?
  #     true
  #   when .nouns?, .comma?, .pro_per?, .popens?
  #     false
  #   else
  #     prev.key == "在" ? true : by_succ > 1
  #   end
  # end

  # # 0 : not a clause, 1: decide by prev values, 2: is a clause!
  # def check_vclause_by_succ?(succ : MtNode?)
  #   return 1 unless succ
  #   return 2 if succ.v_shi? || succ.v_you? || succ.vmodals?
  #   return 1 if succ.verbs? || succ.adverbs? || succ.preposes?

  #   # TODO: check more here
  #   return 0 if succ.comma?
  #   succ.ends? ? 1 : 0
  # end
end

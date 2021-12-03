module CV::TlRule
  def fold_ude1!(node : MtNode, prev = node.prev?, succ = node.succ?) : MtNode
    node.val = ""
    return node unless prev

    case prev
    when .popens?     then return node
    when prev.puncts? then return node.set!("đích")
    when .names?, .pro_per?
      return node if (succ = node.succ?) && !succ.pstops?
    else
      # TODO: handle more case with prev
      return node
    end

    prev.prev? do |x|
      return node if x.verbs? || x.preposes? || x.nouns? || x.pronouns?
    end

    node.val = "của"
    fold_swap!(prev, node, PosTag::DefnPhrase, dic: 8)
  end

  def fold_noun_ude1!(node : MtNode, prev = node.prev) : MtNode
    node.succ? { |succ| return node if succ.penum? || succ.concoord? }
    return node unless prev_2 = prev.prev?

    prev.val = ""

    case prev_2
    when .ajad?
      prev_2.val = "thông thường" if prev_2.key == "一般"
      fold_swap!(prev_2, node, PosTag::NounPhrase, dic: 4)
    when .adjts?
      if (prev_3 = prev_2.prev?) && prev_3.noun?
        prev_2 = fold!(prev_3, prev, PosTag::DefnPhrase, dic: 8)
      end

      fold_swap!(prev_2, node, PosTag::NounPhrase, dic: 4)
    when .veno?, .vintr?, .verb_object?,
         .time?, .place?, .space?,
         .pro_dem?, .modifier?,
         .defn_phrase?, .prep_phrase?
      prev_2 = fold!(prev_2, prev, PosTag::DefnPhrase, dic: 7)
      fold_swap!(prev_2, node, PosTag::NounPhrase, dic: 4)
    when .numeric?
      fold_swap!(prev_2, node, PosTag::NounPhrase, dic: 4)
    when .nouns?, .pro_per?
      if (prev_3 = prev_2.prev?) && is_verb_clause?(prev_3, node)
        prev = fold!(prev_3, prev, PosTag::DefnPhrase, dic: 9)
        return fold_swap!(prev, node, PosTag::NounPhrase, dic: 6)
      end

      prev.val = "của"
      dic = prev_2.prev?(&.verbs?) ? 6 : 4
      return fold_swap!(prev_2, node, PosTag::NounPhrase, dic: dic)
    when .verb?
      return node unless prev_3 = prev_2.prev?
      # puts [prev_3, prev_2]

      case prev_3.tag
      when .nouns?
        if (prev_4 = prev_3.prev?) && prev_4.pre_bei?
          head = fold!(prev_4, prev_2, PosTag::DefnPhrase, dic: 8)
        else
          head = fold!(prev_3, prev_2, PosTag::DefnPhrase, dic: 9)
        end
        fold_swap!(head, node, PosTag::NounPhrase, dic: 9)
      when .nquants?
        node = fold_swap!(prev_2, node, PosTag::NounPhrase, dic: 8)
        fold!(prev_3, node, PosTag::NounPhrase, 3)
      else
        node
      end
    else
      node
    end
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

module CV::TlRule
  def fold_ude1!(node : MtNode, prev = node.prev) : MtNode
    node.succ? { |succ| return node if succ.penum? || succ.concoord? }
    return node unless prev_2 = prev.prev?

    prev.val = ""

    case prev_2
    when .ajav?
      prev_2.val = "thông thường" if prev_2.key == "一般"
      return fold_swap!(prev_2, node, PosTag::Nphrase, dic: 4)
    when .adjts?, .veno?, .vintr?,
         .time?, .place?, .space?,
         .adesc?, .pro_dem?, .dphrase?
      return fold_swap!(prev_2, node, PosTag::Nphrase, dic: 4)
    when .nquants?
      return fold_swap!(prev_2, node, PosTag::Nphrase, dic: 4)
    when .nouns?, .pro_per?
      if (prev_3 = prev_2.prev?) && is_verb_clause?(prev_3, node)
        prev = fold!(prev_3, prev, PosTag::Dphrase, dic: 9)
        return fold_swap!(prev, node, PosTag::Nphrase, dic: 6)
      end

      prev.val = "của"
      dic = prev_2.prev?(&.verbs?) ? 6 : 4
      return fold_swap!(prev_2, node, PosTag::Nphrase, dic: dic)
    when .verb?
      return node unless prev_3 = prev_2.prev?

      if prev_3.nouns?
        if (prev_4 = prev_3.prev?) && prev_4.pre_bei?
          head = fold!(prev_4, prev_2, PosTag::Dphrase, dic: 8)
        else
          head = fold_swap!(prev_3, prev_2, PosTag::Dphrase, dic: 8)
        end
        return fold_swap!(head, node, PosTag::Nphrase, dic: 9)
      elsif prev_3.nquant?
        node = fold_swap!(prev_2, node, PosTag::Nphrase, dic: 8)
        return fold!(prev_3, node, PosTag::Nphrase, 3)
      end

      # TODO
      node
    else
      node
    end
  end

  def is_verb_clause?(head : MtNode, tail : MtNode)
    return false unless head.v_you? || head.verb? || head.vphrase?

    by_succ = check_vclause_by_succ?(tail.succ?)
    return by_succ == 2 unless prev = head.prev?

    case prev.tag
    when .v_shi?, .verb?, .nquants?, .pro_dems?
      true
    when .nouns?, .comma?
      false
    else
      prev.key == "在" ? true : by_succ > 0
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

module CV::TlRule
  # ameba:disable Metrics/CyclomaticComplexity
  def fold_noun_verb!(noun : MtNode, verb : MtNode)
    if (prev = noun.prev?) && do_not_fold_noun_verb?(prev)
      return noun.flag!(:checked)
    end

    verb = fold_verbs!(verb)
    return fold_noun_other!(noun) unless verb.verbal?

    head = fold!(noun, verb, PosTag::VerbClause, dic: 4)
    return head unless succ = head.succ?

    case succ
    when .ude1?
      fold_ude1!(ude1: succ, left: head)
    when .suffixes?
      fold_suffix!(head, succ)
    else
      head
    end
  end

  def do_not_fold_noun_verb?(prev : MtNode)
    prev.ude1? || prev.pro_per? || prev.preposes? && !prev.pre_bi3?
  end
end

module MtlV2::TlRule
  # ameba:disable Metrics/CyclomaticComplexity
  def fold_noun_verb!(noun : BaseNode, verb : BaseNode)
    # puts [noun, verb].colorize.green

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

  def do_not_fold_noun_verb?(prev : BaseNode)
    return !prev.pre_bi3? if prev.preposes?
    prev.ude1? || prev.pronouns? || prev.numeral? || prev.defn_phrase?
  end
end

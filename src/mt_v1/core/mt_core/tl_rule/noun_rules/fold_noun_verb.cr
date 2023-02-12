module M1::TlRule
  # ameba:disable Metrics/CyclomaticComplexity
  def fold_noun_verb!(noun : MtNode, verb : MtNode)
    return noun if noun.prev? { |x| x.pro_per? || x.preposes? && !x.pre_bi3? }

    verb = verb.vmodals? ? fold_vmodals!(verb) : fold_verbs!(verb)
    return noun unless (succ = verb.succ?) && succ.ude1?

    # && (verb.verb? || verb.vmodals?)
    return noun unless tail = scan_noun!(succ.succ?)
    case tail.key
    when "时候"
      noun = fold!(noun, succ.set!(""), PosTag::DefnPhrase, dic: 7)
      return fold!(noun, tail.set!("lúc"), PosTag::Ntime, dic: 9, flip: true)
    end

    # if verb.verb_no_obj? && (verb_2 = tail.succ?) && verb_2.maybe_verb?
    #   verb_2 = verb_2.adverbial? ? fold_adverbs!(verb_2) : fold_verbs!(verb_2)

    #   if !verb_2.verb_no_obj? && verb.prev?(&.object?)
    #     tail = fold!(tail, verb_2, PosTag::VerbClause, dic: 8)
    #     noun = fold!(noun, verb, PosTag::VerbClause, dic: 7)
    #     return fold!(noun, succ.set!(""), dic: 9, flip: true)
    #   end
    # end

    left = fold!(noun, verb, PosTag::VerbPhrase, dic: 4)

    defn = fold!(left, succ.set!(""), PosTag::DefnPhrase, dic: 6, flip: true)
    tag = tail.names? || tail.human? ? tail.tag : PosTag::NounPhrase

    fold!(defn, tail, tag, dic: 5, flip: true)
  end
end

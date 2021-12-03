module CV::TlRule
  def fold_verb_ude1!(verb : MtNode, ude1 : MtNode, right : MtNode)
    return right unless prev = verb.prev?
    # puts [prev, verb]

    case prev.tag
    when .nouns?
      if (prev_2 = prev.prev?) && prev_2.pre_bei?
        head = fold!(prev_2, verb, PosTag::DefnPhrase, dic: 8)
      else
        head = fold!(prev, verb, PosTag::DefnPhrase, dic: 9)
      end
      fold_swap!(head, right, PosTag::NounPhrase, dic: 9)
    when .quantis?, .nquants?
      verb = fold_swap!(verb, right, PosTag::NounPhrase, dic: 8)
      fold!(prev, verb, PosTag::NounPhrase, 3)
    else
      right
    end
  end
end

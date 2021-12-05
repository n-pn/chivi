module CV::TlRule
  def fold_verb_ude1!(verb : MtNode, ude1 : MtNode, right : MtNode, mode = 0)
    return ude1 unless (prev = verb.prev?) && prev.center_noun?
    # puts [prev, verb, "fold_verb_ude1!"]
    # TODO: fix this shit!

    case prev.tag
    when .nouns?
      if (prev_2 = prev.prev?) && prev_2.pre_bei?
        head = fold!(prev_2, verb, PosTag::DefnPhrase, dic: 8)
      else
        head = fold!(prev, verb, PosTag::DefnPhrase, dic: 9)
      end
      fold!(head, right, PosTag::NounPhrase, dic: 9, flip: true)
    when .quantis?, .nquants?
      verb = fold!(verb, right, PosTag::NounPhrase, dic: 8, flip: true)
      fold!(prev, verb, PosTag::NounPhrase, 3)
    else
      ude1
    end
  end
end

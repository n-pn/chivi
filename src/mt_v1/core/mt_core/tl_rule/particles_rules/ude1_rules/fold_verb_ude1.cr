module M1::TlRule
  def fold_verb_ude1!(verb : MtNode, ude1 : MtNode, right : MtNode, mode = 0)
    return ude1 unless (prev = verb.prev?) && prev.subject?
    # puts [prev, verb, "fold_verb_ude1!"]
    # TODO: fix this shit!

    case prev.tag
    when .nominal?
      if verb.verb?
        head = fold!(prev, ude1, PosTag::DefnPhrase, dic: 7)
      else
        head = fold!(verb, ude1, PosTag::DefnPhrase, dic: 7)
      end

      fold!(head, right, PosTag::NounPhrase, dic: 6, flip: true)
    when .quantis?, .nquants?
      verb = fold!(verb, right, PosTag::NounPhrase, dic: 8, flip: true)
      fold!(prev, verb, PosTag::NounPhrase, 3)
    else
      ude1
    end
  end
end

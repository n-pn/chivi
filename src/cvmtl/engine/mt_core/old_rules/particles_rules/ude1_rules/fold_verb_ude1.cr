module MT::TlRule
  def fold_verb_ude1!(verb : MtNode, ude1 : MtNode, right : MtNode, mode = 0)
    return ude1 unless (prev = verb.prev?) && prev.content?
    # puts [prev, verb, "fold_verb_ude1!"]
    # TODO: fix this shit!

    case prev.tag
    when .noun_words?
      if verb.verb?
        head = fold!(prev, ude1, PosTag::DcPhrase)
      else
        head = fold!(verb, ude1, PosTag::DcPhrase)
      end

      fold!(head, right, PosTag::Nform, flip: true)
    when .quantis?, .nquants?
      verb = fold!(verb, right, PosTag::Nform, flip: true)
      fold!(prev, verb, PosTag::Nform, 3)
    else
      ude1
    end
  end
end

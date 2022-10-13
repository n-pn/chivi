module MT::TlRule
  def fold_verb_ude1!(verb : BaseNode, ude1 : BaseNode, right : BaseNode, mode = 0)
    return ude1 unless (prev = verb.prev?) && prev.content?
    # puts [prev, verb, "fold_verb_ude1!"]
    # TODO: fix this shit!

    case prev.tag
    when .noun_words?
      if verb.verb?
        head = fold!(prev, ude1, MapTag::DcPhrase)
      else
        head = fold!(verb, ude1, MapTag::DcPhrase)
      end

      fold!(head, right, MapTag::Nform, flip: true)
    when .quantis?, .nquants?
      verb = fold!(verb, right, MapTag::Nform, flip: true)
      fold!(prev, verb, MapTag::Nform, 3)
    else
      ude1
    end
  end
end

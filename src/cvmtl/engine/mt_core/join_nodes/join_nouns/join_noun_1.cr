module MT::Core
  def join_noun_1!(noun : MtNode, prev = noun.prev)
    case noun
    when .honor?          then return join_honor!(noun, prev)
    when .proper_nouns?   then return join_name!(noun, prev)
    when .locat?, .posit? then return fold!(prev, noun, PosTag::Posit, flip: true)
    when .nattr?
      return fold!(prev, noun, {noun.tag, noun.pos}, flip: true) if prev.nattr?
    end

    case prev
    when .posit?, .nattr?
      flip = true
    else
      flip = should_flip_noun?(prev.prev?, noun.succ?)
    end

    fold!(prev, noun, PosTag::Nform, flip: flip)
    # next_is_verb = noun.succ? { |x| x.verb_words? || x.preposes? }
  end

  def should_flip_noun?(prev, succ)
    return true unless succ && prev && prev.verb_words?
    return false if prev.vtwo?
    succ.verb_words?
  end
end

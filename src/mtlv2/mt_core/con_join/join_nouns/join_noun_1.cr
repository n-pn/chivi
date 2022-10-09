module MT::Core
  def join_noun_1!(noun : BaseNode, prev : BaseNode)
    case noun
    when .honor?          then return join_honor!(noun, prev)
    when .proper_nouns?   then return join_name!(noun, prev)
    when .locat?, .posit? then return fold!(prev, noun, MapTag::Posit, flip: true)
    when .nattr?
      return fold!(prev, noun, noun.tag, flip: true) if prev.nattr?
    end

    case prev
    when .posit?, .nattr?
      flip = true
    else
      flip = should_flip_noun?(prev.prev?, noun.succ?)
    end

    fold!(prev, noun, MapTag::Nform, dic: 5, flip: flip)
    # next_is_verb = noun.succ? { |x| x.verb_words? || x.preposes? }
  end

  def should_flip_noun?(prev, succ)
    return true unless succ && prev && prev.verb_words?
    return false if prev.vtwo?
    succ.verb_words?
  end

  def join_honor!(noun, prev)
    case prev
    when .time_words?, .nform?, .locat?, .posit?
      ptag = MapTag::Nform
    else
      ptag = MapTag::CapHuman
    end

    fold!(prev, noun, ptag, dic: 4, flip: false)
  end

  def join_name!(name, prev)
    case prev
    when .cap_affil?
      return fold!(prev, name, name.tag, flip: true)
    when .cap_human?
      return fold!(prev, name, name.tag, flip: false) if name.cap_human?
    end

    fold!(prev, name, MapTag::Nform, dic: 5, flip: false)
  end
end

module MT::Core
  def pair_noun!(noun : MtNode)
    while prev = noun.prev
      prev = fix_mixedpos!(prev) if prev.mixedpos?
      break unless prev.noun_words?
      tag, pos, flip = noun_pairing_type(noun, prev)
      noun = PairNode.new(prev, noun, tag, pos, flip: flip)
    end

    return noun if !prev.adjt_words? || prev.aform?
    return noun if prev.prev? { |x| x.advb_words? || x.maybe_advb? }

    PairNode.new(prev, noun, flip: !prev.at_head?)
  end

  private def noun_pairing_type(noun : MtNode, prev : MtNode) : {MtlTag, MtlPos, Bool}
    case noun
    when .honor?        then honor_pairing_type(noun, prev)
    when .proper_nouns? then named_pairing_type(noun, prev)
    when .locat?, .posit?
      tag, pos = PosTag::Posit
      {tag, pos, true}
    when .nattr?
      {noun.tag, noun.pos, prev.nattr?}
    else
      other_pairing_type(noun, prev)
    end
  end

  private def honor_pairing_type(noun : MtNode, prev : MtNode)
    case prev
    when .time_words?, .nform?, .locat?, .posit?
      tag, pos = PosTag::Nform
    else
      tag, pos = PosTag::CapHuman
    end

    {tag, pos, false}
  end

  private def named_pairing_type(name : MtNode, prev : MtNode)
    tag, pos = PosTag::Nform

    case prev
    when .cap_affil?
      {name.tag, name.pos, true}
    when .cap_human?
      {name.tag, name.pos, name.cap_human?}
    when .proper_nouns?
      {MtlTag::CapOther, pos, true}
    else
      {tag, pos, false}
    end
  end

  private def other_pairing_type(noun : MtNode, prev : MtNode)
    flip = prev.posit? || prev.nattr? || should_flip_noun?(prev.prev?, noun.succ?)
    {noun.tag, noun.pos, flip}
  end

  private def should_flip_noun?(prev, succ)
    return true unless succ && prev && prev.verb_words?
    return false if prev.vtwo?
    succ.verb_words?
  end
end

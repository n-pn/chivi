module MT::Rules
  def foldl_noun_base!(noun : MtNode)
    while prev = noun.prev
      prev = fix_mixedpos!(prev) if prev.mixedpos?

      break unless prev.all_nouns?
      tag, pos, flip = noun_pairing_type(noun, prev)
      noun = PairNode.new(prev, noun, tag, pos, flip: flip)
    end

    return noun if !prev.adjt_words? || prev.amix?
    return noun if prev.prev? { |x| x.advb_words? || x.maybe_advb? }

    PairNode.new(prev, noun, flip: !prev.at_head?)
  end

  private def noun_pairing_type(noun : MtNode, prev : MtNode) : {MtlTag, MtlPos, Bool}
    case noun
    when .honor?      then honor_pairing_type(noun, prev)
    when .name_words? then named_pairing_type(noun, prev)
    when .posit?, .locat_words?
      tag, pos = PosTag.make(:posit)
      {tag, pos, true}
    when .nattr?
      {noun.tag, noun.pos, prev.nattr?}
    else
      other_pairing_type(noun, prev)
    end
  end

  private def honor_pairing_type(noun : MtNode, prev : MtNode)
    case prev
    when .all_times?, .nmix?, .posit?, .locat_words?
      tag, pos = PosTag.make(:nmix)
    else
      tag, pos = PosTag.make(:human_name)
    end

    {tag, pos, false}
  end

  private def named_pairing_type(name : MtNode, prev : MtNode)
    tag, pos = PosTag.make(:nmix)

    case prev
    when .place_name?
      {name.tag, name.pos, true}
    when .human_name?
      {name.tag, name.pos, name.human_name?}
    when .name_words?
      {MtlTag::OtherName, pos, true}
    else
      {tag, pos, false}
    end
  end

  private def other_pairing_type(noun : MtNode, prev : MtNode)
    flip = prev.posit? || prev.nattr? || should_flip_noun?(prev.prev?, noun.succ?)
    {noun.tag, noun.pos, flip}
  end

  private def should_flip_noun?(prev, succ)
    return true unless succ && prev && prev.verbal_words?
    return false if prev.vtwo?
    succ.verbal_words?
  end
end

module MT::Rules
  def foldl_noun_base!(noun : MtNode)
    while prev = noun.prev
      # puts [noun, prev]
      # prev = fix_mixedpos!(prev) if prev.mixedpos?

      case prev
      when .all_times?
        prev = foldl_time_base!(prev)
        # Do not combine if time is adverb phrase
        return noun if prev.prev?(&.boundary?)
      when .adjt_words?, .hao_word?, .maybe_adjt?
        return noun if prev.amix? || prev.ades? || prev.prev?(&.advb_words?)
        return PairNode.new(prev, noun, flip: !prev.at_head?)
      when .verb_no_obj?, .verb_or_noun?
        return noun if prev.prev?(&.advb_words?)
        return PairNode.new(prev, noun, flip: !prev.at_head?)
      else
        break unless prev.all_nouns?
      end

      tag, pos, flip = noun_pairing_type(noun, prev)

      noun = PairNode.new(prev, noun, tag, pos, flip: flip)
    end

    noun
  end

  private def noun_pairing_type(noun : MtNode, prev : MtNode) : {MtlTag, MtlPos, Bool}
    case noun
    when .posit?, .locat_words?
      tag, pos = PosTag.make(:posit)
      {tag, pos, true}
    when .nattr?
      {noun.tag, noun.pos, true}
    else
      other_pairing_type(noun, prev)
    end
  end

  private def other_pairing_type(noun : MtNode, prev : MtNode)
    flip = prev.posit? || prev.nattr? || should_flip_noun?(prev.prev?, noun.succ?)
    {noun.tag, noun.pos | prev.pos, flip}
  end

  private def should_flip_noun?(prev, succ)
    return true unless succ && prev && prev.verbal_words?
    return false if prev.vtwo?
    !succ.verbal_words?
  end
end

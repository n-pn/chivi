module MT::Core
  def pair_noun!(noun : MtNode, prev = noun.prev)
    case noun
    when .honor?          then return pair_nhonor!(noun, prev)
    when .proper_nouns?   then return pair_proper!(noun, prev)
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

    PairNode.new(prev, noun, PosTag::Nform, flip: flip)
  end

  def should_flip_noun?(prev, succ)
    return true unless succ && prev && prev.verb_words?
    return false if prev.vtwo?
    succ.verb_words?
  end

  def pair_nhonor!(noun : MtNode, prev : MtNode)
    case prev
    when .time_words?, .nform?, .locat?, .posit?
      tag, pos = PosTag::Nform
    else
      tag, pos = PosTag::CapHuman
    end

    PairNode.new(prev, noun, tag, pos)
  end

  def pair_proper!(name : MtNode, prev : MtNode)
    case prev
    when .cap_affil?
      return PairNode.new(prev, name, flip: true)
    when .cap_human?
      return PairNode.new(prev, name, flip: false) if name.cap_human?
    end

    PairNode.new(prev, name, PosTag::Nform)
  end
end

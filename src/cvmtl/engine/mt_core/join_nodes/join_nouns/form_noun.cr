module MT::Core
  def form_noun!(noun : MtNode, prev = noun.prev) : MtNode
    # if prev.adjt_words?
    #   noun = PairNode.new(prev, noun, flip: !prev.at_head?)
    #   prev = noun.prev
    # end

    if prev.pt_deps?
      noun = form_noun_udep!(noun, udep: prev.as(MonoNode))
      return noun unless noun.tag.noun_words?
      prev = noun.prev
    end

    # if prev.can_split? # for nquant or pro_dem/pro_int that can be splitted
    #   _, prev = split_mono!(prev)
    # end

    if prev.quantis? || prev.nquants?
      prev.as(MonoNode).inactivate! if prev.tag.qt_ge4?
      noun = PairNode.new(prev, noun, flip: false)
      prev = noun.prev
    end

    if prev.numbers?
      noun = PairNode.new(prev, noun, flip: prev.ordinal?)
      return noun unless prev = noun.prev?
    end

    if prev.pro_dems? || prev.pro_na2?
      noun = PairNode.new(prev, noun, flip: prev.at_tail?)
      return noun unless prev = noun.prev?
    end

    return noun unless prev.pronouns?
    PairNode.new(prev, noun, flip: noun.tag.posit?)
  end

  def form_noun_udep!(noun : MtNode, udep : MonoNode, head = udep.prev)
    tag = MtlTag::DcPhrase
    pos = MtlPos::AtTail

    head = join_word!(head)

    if head.ktetic?
      udep.val = "của"
    else
      udep.inactivate!
    end

    TrioNode.new(head, udep, noun, tag: tag, pos: pos, type: :flip_all)
  end
end

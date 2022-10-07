module CV::TlRule
  # ameba:disable Metrics/CyclomaticComplexity
  def fold_noun_noun!(node : BaseNode, succ : BaseNode, mode = 0)
    return unless node.nattr? || noun_can_combine?(node.prev?, succ.succ?)

    case succ.tag
    when .honor?
      if node.proper_nouns? || node.honor?
        fold!(node, succ, PosTag::Person, dic: 3)
      else
        fold!(node, succ, PosTag::Person, dic: 3, flip: true)
      end
    when .proper_nouns?
      fold!(node, succ, succ.tag, dic: 4)
    when .posit?
      fold!(node, succ, PosTag::DcPhrase, dic: 3, flip: true)
      # when .locality?
      #   fold_noun_space!(node, succ) if mode == 0
    else
      if (prev = node.prev?) && prev.vtwo?
        flip = succ.succ?(&.content?) || false
      else
        flip = true
      end

      tag = node.tag == succ.tag ? node.tag : PosTag::Noun
      fold!(node, succ, tag, dic: 3, flip: flip)
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def noun_can_combine?(prev : BaseNode?, succ : BaseNode?) : Bool
    while prev && (prev.numeral? || prev.pronouns?)
      # puts [prev, succ, "noun_can_combine"]
      prev = prev.prev?
    end

    return true if !prev || prev.preposes?
    return true if !succ || succ.content? || succ.boundary? || succ.v_shi? || succ.v_you?

    # puts [prev, succ, "noun_can_combine"]
    case succ
    when .maybe_adjt?
      return false unless (tail = succ.succ?) && tail.pt_dep?
      tail.succ? { |x| x.boundary? || x.verbal? } || false
    when .preposes?, .verbal?
      return true if succ.succ? { |x| x.pt_dep? || x.boundary? }
      return false if prev.boundary?
      is_linking_verb?(prev, succ)
    else
      true
    end
  end
end

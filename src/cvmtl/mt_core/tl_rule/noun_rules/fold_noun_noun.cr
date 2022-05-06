module CV::TlRule
  # ameba:disable Metrics/CyclomaticComplexity

  def fold_noun_noun!(node : MtNode, succ : MtNode, mode = 0)
    return unless node.nattr? || noun_can_combine?(node.prev?, succ.succ?)

    case succ.tag
    when .ptitle?
      if node.names? || node.ptitle?
        fold!(node, succ, PosTag::Person, dic: 3)
      else
        fold!(node, succ, PosTag::Person, dic: 3, flip: true)
      end
    when .names?
      fold!(node, succ, succ.tag, dic: 4)
    when .times?
      fold!(node, succ, PosTag::NounPhrase, dic: 4)
    when .place?
      fold!(node, succ, PosTag::DefnPhrase, dic: 3, flip: true)
      # when .space?
      #   fold_noun_space!(node, succ) if mode == 0
    else
      if (prev = node.prev?) && need_2_objects?(prev)
        flip = succ.succ?(&.subject?) || false
      else
        flip = true
      end

      tag = node.tag == succ.tag ? node.tag : PosTag::Noun
      fold!(node, succ, tag, dic: 3, flip: flip)
    end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def noun_can_combine?(prev : MtNode?, succ : MtNode?) : Bool
    while prev && (prev.numeric? || prev.pronouns?)
      # puts [prev, succ, "noun_can_combine"]
      prev = prev.prev?
    end

    return true if !prev || prev.preposes?
    return true if !succ || succ.subject? || succ.ends? || succ.v_shi? || succ.v_you?

    # puts [prev, succ, "noun_can_combine"]
    case succ
    when .maybe_adjt?
      return false unless (tail = succ.succ?) && tail.ude1?
      tail.succ? { |x| x.ends? || x.verbs? } || false
    when .preposes?, .verbs?
      return true if succ.succ? { |x| x.ude1? || x.ends? }
      return false if prev.ends?
      is_linking_verb?(prev, succ)
    else
      true
    end
  end
end

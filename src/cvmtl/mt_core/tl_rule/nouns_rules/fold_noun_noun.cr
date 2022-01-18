module CV::TlRule
  def fold_noun_noun!(node : MtNode, succ : MtNode, mode = 0)
    return unless noun_can_combine?(node.prev?, succ.succ?)

    case succ.tag
    when .nmorp?
      fold!(node, succ, node.tag, dic: 4)
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
      fold!(node, succ, PosTag::Noun, dic: 3, flip: true)
    end
  end

  def noun_can_combine?(prev : MtNode?, succ : MtNode?) : Bool
    while prev && (prev.numeric? || prev.pronouns?)
      prev = prev.prev?
    end

    # puts [prev, succ, "noun_can_combine"]

    return true unless prev && !prev.preposes?
    # return false if succ.maybe_adjt?

    while succ
      case succ
      when .adjts?   then return !succ.succ?(&.ude1?)
      when .adverbs? then succ = succ.succ?
      when .preposes?, .verbs?
        return is_linking_verb?(prev, succ) || prev.ends?
      else return true
      end
    end

    true
  end
end
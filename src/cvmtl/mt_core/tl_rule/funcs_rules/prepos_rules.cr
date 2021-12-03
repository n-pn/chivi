module CV::TlRule
  def fold_preposes!(node : MtNode, succ = node.succ?) : MtNode
    return node unless succ

    # TODO!
    case node.tag
    when .pre_dui? then fold_pre_dui!(node, succ)
    when .pre_bei? then fold_pre_bei!(node, succ)
    when .pre_zai? then fold_pre_zai!(node, succ)
    else                fold_prepos!(node, succ)
    end
  end

  def fold_pre_dui!(node : MtNode, succ = node.succ?) : MtNode
    return node.set!("đúng", PosTag::Unkn) unless succ && !succ.ends?

    # TODO: combine grammar

    case succ.tag
    when .ude1?
      fold!(node.set!("đúng"), succ.set!(""), PosTag::Unkn, dic: 7)
    when .ule?
      succ.val = "" unless keep_ule?(node, succ)
      fold!(node.set!("đúng"), succ, PosTag::Unkn, dic: 7)
    when .ends?, .conjunct?, .concoord?
      node.set!("đúng", PosTag::Adjt)
    when .contws?, .popens?
      fold_prepos!(node.set!("đối với"), succ)
    else
      node
    end
  end

  def fold_pre_bei!(node : MtNode, succ = node.succ?) : MtNode
    return node unless succ

    if succ.verb?
      # todo: change "bị" to "được" if suitable
      node = fold!(node, succ, succ.tag, dic: 5)
      fold_verbs!(node)
    else
      fold_prepos!(node, succ)
    end
  end

  def fold_pre_zai!(node : MtNode, succ = node.succ?) : MtNode
    fold_prepos!(node, succ)

    # return node unless succ && succ.nouns?
    # succ = fold_noun!(succ)
    # if (succ_2 = succ.succ?) && succ_2.space?
    #   succ = fold_noun_space!(succ, succ_2)
    # end

    # # puts [node, succ, succ.succ?]
    # return node unless succ.succ?(&.ude1?)

    # node.val = "ở"

    # if (prev = node.prev?) && prev.verbs?
    #   node = prev
    # end

    # fold!(node, succ, PosTag::DefnPhrase, dic: 9)
  end

  def fold_prepos!(node : MtNode, succ = node.succ?) : MtNode
    return node unless succ && !succ.ends?
    succ = scan_noun!(succ, mode: 1)

    return node unless tail = succ.succ?

    case tail.tag
    when .verb?, .verb_object?
      if (succ.nouns? || succ.pro_per?)
        # TODO: put more block after verb

        if node.key == "给"
          swap = true
          node.val = "cho"
        end

        node = fold!(node, succ, PosTag::PrepPhrase, dic: 5)

        tail = fold_verbs!(tail)

        if tail.verb? && (tail_noun = tail.succ?) && !tail_noun.ends?
          tail_noun = scan_noun!(tail_noun)

          if tail_noun.nouns?
            tail = fold!(tail, tail_noun, PosTag::VerbObject, dic: 8)
          end
        end

        if swap
          return fold_swap!(node, tail, tail.tag, dic: 6)
        else
          return fold!(node, tail, tail.tag, dic: 6)
        end
      end
    when .uls?
      # TODO
    end

    if tail.ude1? && (tail_2 = tail.succ?)
      tail_2 = scan_noun!(tail_2)
      # puts [node, succ, tail, tail_2, "prepos"]

      if (tail_3 = tail_2.succ?) && (tail_3.maybe_verb?)
        succ = fold_ude1_left!(tail_2, tail)
        node = fold!(node, succ, PosTag::PrepPhrase, dic: 7)

        tail = tail_3.adverbs? ? fold_adverbs!(tail_3) : fold_verbs!(tail_3)
        return fold!(node, tail, tail.tag, dic: 8)
      end

      node = fold!(node, succ, PosTag::PrepPhrase, dic: 5)
      return fold_ude1_left!(tail_2, tail)
    end

    fold!(node, succ, PosTag::PrepPhrase, dic: 5)
  end
end

module CV::TlRule
  def fold_noun!(node : MtNode, mode : Int32 = 0) : MtNode
    # return node if node.nform?

    while node.nouns?
      break unless succ = node.succ?

      case succ
      when .uniques?
        case succ.key
        when "第"
          node = fold_swap!(node, fold_第!(succ), succ.tag, dic: 6)
        else
          # TODO!
          break
        end
      when .maybe_adjt?
        return node unless node.prev?(&.nouns?)
        succ = succ.adverbs? ? fold_adverbs!(succ) : fold_adjts!(succ)
        return fold!(node, succ, PosTag::Aform, dic: 6)
      when .middot?
        break unless (succ_2 = succ.succ?) && succ_2.human?
        return fold!(node, succ_2, PosTag::Person, dic: 3)
      when .uzhi?
        # TODO: check with prev to group
        return fold_uzhi!(succ, node)
      when .veno?
        succ = heal_veno!(succ)
        return node if succ.verbs?
        node = fold_swap!(node, succ, PosTag::Noun, dic: 7)
      when .penum?, .concoord?
        return node unless fold = fold_noun_concoord!(succ, node)
        node = fold
      when .nouns?
        return node unless fold = fold_noun_noun!(node, succ)
        node = fold
      when .suf_verb?
        return fold_suf_verb!(node, succ)
      when .suf_nouns?
        return fold_suf_noun!(node, succ)
      else break
      end

      break if succ == node.succ?
    end

    node
  end

  def fold_noun_noun!(node : MtNode, succ : MtNode)
    return unless noun_can_combine?(node.prev?, succ.succ?)

    case succ.tag
    when .nmorp?
      fold!(node, succ, node.tag, dic: 4)
    when .ptitle?
      if node.names?
        fold!(node, succ, PosTag::Person, dic: 3)
      else
        fold_swap!(node, succ, PosTag::Person, dic: 3)
      end
    when .names?
      fold!(node, succ, succ.tag, dic: 4)
    when .place?
      fold_swap!(node, succ, PosTag::DefnPhrase, dic: 3)
    when .space?
      fold_swap!(node, succ, PosTag::Space, dic: 3)
    else
      fold_swap!(node, succ, PosTag::Noun, dic: 3)
    end
  end

  def noun_can_combine?(prev : MtNode?, succ : MtNode?) : Bool
    while prev && (prev.nquants? || prev.pronouns?)
      prev = prev.prev?
    end

    return true unless prev && succ

    case succ
    when .maybe_adjt?
      false
    when .maybe_verb?
      prev.preposes? || prev.verbs? && is_linking_verb?(prev, succ)
    else
      true
    end
  end
end

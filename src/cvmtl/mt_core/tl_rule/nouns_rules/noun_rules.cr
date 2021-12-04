module CV::TlRule
  def fold_noun!(noun : MtNode, mode : Int32 = 0) : MtNode
    # return node if node.nform?

    while noun.nouns?
      break unless succ = noun.succ?
      # puts [noun, succ]

      case succ
      when .uniques?
        case succ.key
        when "第"
          noun = fold_swap!(noun, fold_第!(succ), succ.tag, dic: 6)
        else
          # TODO!
          break
        end
      when .maybe_adjt?
        return noun unless noun.prev?(&.nouns?)
        succ = succ.adverbs? ? fold_adverbs!(succ) : fold_adjts!(succ)
        return noun.succ?(&.ude1?) ? fold!(noun, succ, PosTag::Aform, dic: 6) : noun
      when .middot?
        break unless (succ_2 = succ.succ?) && succ_2.human?
        noun = fold!(noun, succ_2, PosTag::Person, dic: 3)
      when .uzhi?
        # TODO: check with prev to group
        return fold_uzhi!(succ, noun)
      when .veno?
        succ = heal_veno!(succ)
        return noun if succ.verbs?
        noun = fold_swap!(noun, succ, PosTag::Noun, dic: 7)
      when .penum?, .concoord?
        return noun unless fold = fold_noun_concoord!(succ, noun)
        noun = fold
      when .space?
        return mode == 0 ? fold_noun_space!(noun, succ) : noun
      when .nouns?
        return noun unless fold = fold_noun_noun!(noun, succ, mode: mode)
        noun = fold
      when .suf_verb?
        return fold_suf_verb!(noun, succ)
      when .suf_nouns?
        return fold_suf_noun!(noun, succ)
      else break
      end

      break if succ == noun.succ?
    end

    noun
  end

  def fold_noun_noun!(node : MtNode, succ : MtNode, mode = 0)
    return unless noun_can_combine?(node.prev?, succ.succ?)

    case succ.tag
    when .nmorp?
      fold!(node, succ, node.tag, dic: 4)
    when .ptitle?
      if node.names? || node.ptitle?
        fold!(node, succ, PosTag::Person, dic: 3)
      else
        fold_swap!(node, succ, PosTag::Person, dic: 3)
      end
    when .names?
      fold!(node, succ, succ.tag, dic: 4)
    when .times?
      fold!(node, succ, PosTag::NounPhrase, dic: 4)
    when .place?
      fold_swap!(node, succ, PosTag::DefnPhrase, dic: 3)
      # when .space?
      #   fold_noun_space!(node, succ) if mode == 0
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

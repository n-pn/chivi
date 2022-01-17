module CV::TlRule
  # 0: fold all
  # 1: skip uzhi and space and let the caller handle it
  # 2: stop at concoords

  def fold_noun!(noun : MtNode, mode : Int32 = 0) : MtNode
    # return node if node.nform?

    while noun.nouns?
      break unless succ = noun.succ?

      case succ
      when .maybe_adjt?
        succ = succ.adverbs? ? fold_adverbs!(succ) : fold_adjts!(succ)

        case succ_2 = succ.succ?
        when .nil?, .ude1?, .junction?
          return fold!(noun, succ, PosTag::Aform, dic: 6)
        when .ude2?
          adjt = fold!(noun, succ, PosTag::Aform, dic: 6)
          return fold_adjt_ude2!(adjt, succ_2)
        else
          return noun
        end
      when .middot?
        break unless (succ_2 = succ.succ?) && succ_2.human?
        succ.val = ""
        noun = fold!(noun, succ_2, PosTag::Person, dic: 3)
      when .uzhi?
        # TODO: check with prev to group
        return mode == 0 ? fold_uzhi!(succ, noun) : noun
      when .veno?
        succ = heal_veno!(succ)
        return noun if succ.verbs?
        noun = fold!(noun, succ, PosTag::Noun, dic: 7, flip: true)
      when .junction?
        fold_noun_concoord!(succ, noun).try { |fold| noun = fold } || break
      when .spaces?
        return mode == 0 ? fold_noun_space!(noun, succ) : noun
      when .nouns?
        return noun unless fold = fold_noun_noun!(noun, succ, mode: mode)
        noun = fold
      when .suf_verb?
        return fold_suf_verb!(noun, succ)
      when .suf_noun?
        noun = fold_suf_noun!(noun, succ)
      when .usuo?
        break if succ.succ?(&.verbs?)
        noun = fold_suf_noun!(noun, succ)
      when .uniques?
        case succ.key
        when "第"
          noun = fold!(noun, fold_第!(succ), succ.tag, dic: 6, flip: true)
        else
          # TODO!
          break
        end
      else
        break
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
    while prev && (prev.nquants? || prev.pronouns?)
      prev = prev.prev?
    end

    return true unless prev
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

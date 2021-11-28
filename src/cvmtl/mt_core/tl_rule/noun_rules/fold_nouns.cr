module CV::TlRule
  # @[AlwaysInline]
  # def fold_noun_adjt!(noun : MtNode, adjt : MtNode) : MtNode
  #   return node unless can_fold_noun_adjt?(adjt)
  #   return fold!(node, succ, succ.tag, dic: 7)
  # end

  # @[AlwaysInline]
  # private def can_fold_noun_adjt?(adjt : MtNode)
  #   # TODO: add more cases
  #   return adjst.succ?(&.ude1?)
  # end

  def fold_noun!(node : MtNode, mode : Int32 = 0) : MtNode
    # return node if node.nform?

    while node.nouns?
      break unless succ = node.succ?

      case succ.tag
      when .uniques?
        case succ.key
        when "第"
          succ = fold_第!(succ)
          node = fold_swap!(node, succ, succ.tag, dic: 6)
        else
          # TODO!
          break
        end
      when .adjts?
        return node unless node.prev?(&.nouns?)
        succ = fold_adjts!(succ)
        return fold!(node, succ, PosTag::Aform, dic: 6)
      when .adverbs?
        return node unless node.prev?(&.nouns?)
        succ = fold_adverbs!(succ)
        return node unless succ.adjts?
        return fold!(node, succ, PosTag::Aform, dic: 6)
      when .middot?
        break unless succ_2 = succ.succ?
        break unless succ_2.human?

        return fold!(node, succ_2, PosTag::Person, dic: 3)
      when .ptitle?
        node.tag = PosTag::Person
        node = fold!(node, succ, PosTag::Person, dic: 3)
      when .names?
        break unless node.names?
        node = fold!(node, succ, succ.tag, dic: 3)
      when .place?
        return fold_swap!(node, succ, PosTag::Dphrase, dic: 3)
        # when .time?
        #   tag = node.time? ? node.tag : PosTag::Nphrase
        #   fold_swap!(node, succ, tag, dic: 4)
      when .uzhi?
        return fold_uzhi!(succ, node)
      when .nmorp?
        node = fold!(node, succ, node.tag, dic: 3)
      when .veno?
        succ = heal_veno!(succ)
        break if succ.verbs?
        node = fold_swap!(node, succ, PosTag::Noun, dic: 7)
      when .noun?
        case node
        when .ajno?
          node = fold_swap!(node, succ, PosTag::Noun, dic: 7)
        when .names?, .noun?
          return node unless noun_can_combine?(node.prev?, succ.succ?)
          node = fold_swap!(node, succ, PosTag::Noun, dic: 3)
        else return node
        end
      when .penum?
        break if mode > 0
        node = fold_noun_penum!(node, succ)
      when .concoord?
        break if mode > 0
        break unless (succ_2 = succ.succ?) && nouns_can_group?(node, succ_2)
        succ = heal_concoord!(succ)
        return fold!(node, succ_2, tag: node.tag, dic: 3)
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

  def noun_can_combine?(prev : MtNode?, succ : MtNode?) : Bool
    return true unless prev && succ
    return true unless prev.ends?

    case succ
    when .verbs?, .adverbs?, .adjts?
      false
    else
      true
    end
  end

  def fold_nquant_noun!(prev : MtNode, node : MtNode)
    prev = clean_个!(prev)
    node = fold!(prev, node, PosTag::Nphrase, dic: 3)
    node
  end

  def fold_noun_left!(node : MtNode, mode = 1)
    flag = 0

    while prev = node.prev?
      case prev
      when .penum?, .concoord?
        break unless (prev_2 = prev.prev?) && nouns_can_group?(node, prev_2)
        prev = heal_concoord!(prev) if prev.concoord?
        node = fold!(prev_2, node, tag: node.tag, dic: 3)
      when .numeric?
        break if node.veno? || node.ajno?
        node = fold_nquant_noun!(prev, node)
        flag = 1
      when .pro_ji?
        return fold!(prev, node, PosTag::Nphrase, dic: 3)
      when .pro_dems?
        return fold_pro_dem_noun!(prev, node)
      when .pro_ints?
        return fold_什么_noun!(prev, node) if prev.key == "什么"
        return fold_swap!(prev, node, PosTag::Nphrase, dic: 3)
      when .amorp?
        break if flag > 0
        node = fold!(prev, node, PosTag::Nphrase, dic: 7)
      when .ajno?, .modifier?
        break if flag > 0
        node = fold_swap!(prev, node, PosTag::Nphrase, dic: 3)
      when .place?
        break if flag > 0
        break unless noun_can_combine?(prev.prev?, node.succ?)
        node = fold_swap!(prev, node, PosTag::Nphrase, dic: 3)
      when .ajad?, .adjts?
        break if flag > 0
        break if prev.key.size > 1
        node = fold_swap!(prev, node, PosTag::Nphrase, dic: 8)
      when .ude1?
        break if mode < 1
        node = fold_ude1!(node, prev)
      else
        break
      end

      break if prev == node.prev?
    end

    node
  end

  def fold_什么_noun!(prev : MtNode, node : MtNode)
    succ = MtNode.new("么", "gì", prev.tag, 1, prev.idx + 1)

    prev.key = "什"
    prev.val = "cái"

    succ.fix_succ!(node.succ?)
    node.fix_succ!(succ)

    fold!(prev, succ, PosTag::Nphrase, dic: 3)
  end
end

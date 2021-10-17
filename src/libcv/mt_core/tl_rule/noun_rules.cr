module CV::TlRule
  def fold_noun!(node : MtNode) : MtNode
    while node.nouns?
      break unless succ = node.succ?

      case succ.tag
      when .adjt?
        break unless succ.succ?(&.ude1?)
        return fold!(node, succ, PosTag::Adjt, dic: 3)
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
        return fold_swap!(node, succ, PosTag::Noun, dic: 3)
      when .uzhi?
        return fold_uzhi!(succ, node)
      when .veno?
        succ = heal_veno!(succ)
        break if succ.verbs?
        node = fold_swap!(node, succ, PosTag::Noun, dic: 4)
      when .noun?
        case node
        when .names?
          node = fold_swap!(node, succ, PosTag::Noun, dic: 3)
        when .noun?, .ajno?
          node = fold_swap!(node, succ, PosTag::Noun, dic: 4)
        else return node
        end
      when .penum?, .concoord?
        break
        break unless (succ_2 = succ.succ?) && can_combine_noun?(node, succ_2)
        succ = heal_concoord!(succ) if succ.concoord?
        fold!(node, succ_2, tag: node.tag, dic: 4)
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

  def fold_noun_left!(node : MtNode, mode = 1)
    while prev = node.prev?
      case prev
      when .penum?, .concoord?
        break unless (prev_2 = prev.prev?) && can_combine_noun?(node, prev_2)
        prev = heal_concoord!(prev) if prev.concoord?
        node = fold!(prev_2, node, tag: node.tag, dic: 3)
      when .nquants?
        break if node.veno? || node.ajno?

        if prev.key.ends_with?('个')
          if prev.key.size > 1
            prev.val = prev.val.sub("cái", "").strip
          elsif prev.prev?(&.pro_dems?)
            prev.val = ""
          end
        end

        node = fold!(prev, node, PosTag::Nphrase, dic: 3)
      when .pro_ji?
        return fold!(prev, node, PosTag::Nphrase, dic: 3)
      when .pro_dems?
        return fold_pro_dem_noun!(prev, node)
      when .pro_ints?
        return fold_什么_noun!(prev, node) if prev.key == "什么"
        return fold_swap!(prev, node, PosTag::Nphrase, dic: 3)
      when .amorp? then node = fold!(prev, node, PosTag::Nphrase, dic: 4)
      when .place?, .adesc?, .ajno?, .modifier?, .modiform?
        node = fold_swap!(prev, node, PosTag::Nphrase, dic: 3)
      when .ajav?, .adjts?
        break if prev.key.size > 1
        node = fold_swap!(prev, node, PosTag::Nphrase, dic: 4)
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

module CV::TlRule
  def fold_noun!(node : MtNode) : MtNode
    while node.nouns?
      break unless succ = node.succ?

      case succ.tag
      when .adjt?
        break unless succ.succ?(&.ude1?)
        return fold!(node, succ, PosTag::Adjt, dic: 2)
      when .middot?
        break unless succ_2 = succ.succ?
        break unless succ_2.human?

        return fold!(node, succ_2, PosTag::Person, dic: 2)
      when .ptitle?
        node.tag = PosTag::Person
        node = fold!(node, succ, PosTag::Person, dic: 2)
      when .names?
        break unless node.names?
        node = fold!(node, succ, succ.tag, dic: 3)
      when .place?
        head, tail = swap!(node, succ)
        return fold!(head, tail, PosTag::Noun, dic: 3)
      when .uzhi?
        return fold_uzhi!(succ, node)
      when .veno?
        succ = heal_veno!(succ)
        break if succ.verbs?

        head, tail = swap!(node, succ)
        node = fold!(head, tail, PosTag::Noun, dic: 4)
      when .noun?
        case node
        when .names?
          head, tail = swap!(node, succ)
          node = fold!(head, tail, PosTag::Noun, dic: 3)
        when .noun?
          head, tail = swap!(node, succ)
          node = fold!(head, tail, PosTag::Noun, dic: 4)
        else return node
        end
      when .penum?, .concoord?
        break unless (succ_2 = succ.succ?) && can_combine_noun?(node, succ_2)
        succ = heal_concoord!(succ) if succ.concoord?
        fold!(node, succ_2, tag: node.tag, dic: 3)
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
    return node if node.veno?

    while prev = node.prev?
      case prev
      when .penum?, .concoord?
        break unless (prev_2 = prev.prev?) && can_combine_noun?(node, prev_2)
        prev = heal_concoord!(prev) if prev.concoord?
        fold!(prev_2, node, tag: node.tag, dic: 3)
      when .nquants?
        break if node.veno? || node.ajno?
        if prev.key.ends_with?('个')
          prev.val = prev.val.sub(" cái", "")
        end
        fold!(prev, node, PosTag::Nphrase, 3)
      when .prodeics?
        node.tag = PosTag::Nphrase
        return fold_prodeic_noun!(prev, node)
      when .prointrs?
        val = prev.key == "什么" ? "cái #{node.val} gì" : "#{node.val} #{prev.val}"
        return node.fold_left!(prev, val)
      when .amorp? then node = fold!(prev, node, PosTag::Nphrase, 3)
      when .place?, .adesc?, .ahao?, .ajno?, .modifier?, .modiform?
        head, tail = swap!(prev, node)
        node = fold!(head, tail, PosTag::Nphrase, 2)
      when .ajav?, .adjt?
        break if prev.key.size > 1
        head, tail = swap!(prev, node)
        node = fold!(head, tail, PosTag::Nphrase, 2)
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
end

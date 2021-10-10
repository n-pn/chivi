module CV::TlRule
  def fold_noun!(node : MtNode) : MtNode
    if node.veno?
      node = heal_veno!(node)
      return node if node.verbs?
    end

    while node.nouns?
      break unless succ = node.succ?

      case succ.tag
      when .adjt?
        break unless succ.succ?(&.ude1?)
        node.tag = PosTag::Adjt
        return node.fold!(succ, dic: 8)
      when .middot?
        break unless succ_2 = succ.succ?
        break unless succ_2.human?

        node.tag = PosTag::Person
        node.fold!(succ, node.val).fold!(succ_2)
      when .ptitle?
        node.tag = PosTag::Person
        pad = succ.val[0]? == '-' ? "" : " "
        node.fold!(succ, "#{node.val}#{pad}#{succ.val}")
      when .names?
        break unless node.names?
        node.tag = succ.tag
        node.fold!(succ)
      when .place?
        node.tag = PosTag::Noun
        node.fold!(succ, "#{succ.val} #{node.val}")
      when .uzhi?
        node = fold_uzhi!(succ, node)
      when .veno?
        succ = heal_veno!(succ)
        break if succ.verbs?

        node.tag = PosTag::Noun
        node.fold!(succ, "#{succ.val} #{node.val}")
      when .noun?
        case node
        when .names?
          node.tag = PosTag::Noun
          node.fold!(succ, "#{succ.val} #{node.val}")
        when .noun?
          node.fold!(succ, "#{succ.val} #{node.val}", dic: 7)
        else return node
        end
      when .concoord?
        node = fold_concoord!(node, succ, succ.succ?)
        return node if node.succ == succ
      when .penum?
        node = fold_penum!(node, succ, succ.succ?)
        return node if node.succ == succ
      when .suf_verb?
        return fold_suf_verb!(node, succ)
      when .suf_nouns?
        return fold_suf_noun!(node, succ)
      else break
      end
    end

    node
  end

  def heal_veno!(node : MtNode)
    return node unless succ = node.succ?

    case succ
    when .puncts?
      tag = node.prev?(&.preposes?) ? PosTag::Verb : PosTag::Noun
      return node.heal!(tag: tag)
    when .suf_nouns?
      return node.heal!(tag: PosTag::Noun)
    when .auxils?
      return node.heal!(tag: PosTag::Verb)
    end

    return node unless prev = node.prev?

    case prev
    when .adverbs?, .preposes?, .vmodals?, .vdir?, .vpro?
      node.heal!(tag: PosTag::Verb)
    when .auxils?
      node.heal!(tag: PosTag::Noun)
    else
      node
    end
  end

  def fold_noun_left!(node : MtNode, mode = 1)
    return node if node.veno?

    while prev = node.prev?
      case prev
      when .penum?
        prev_2 = prev.prev
        break unless prev_2.tag == node.tag || prev_2.propers? || prev_2.prodeics?
        prev_2.tag = node.tag
        node = fold_penum!(prev_2, prev, node, force: true)
      when .concoord?
        prev_2 = prev.prev
        break unless prev_2.tag == node.tag || prev_2.propers? || prev_2.prodeics?
        prev_2.tag = node.tag
        node = fold_concoord!(prev_2, prev, node, force: true)
      when .nquants?
        break if node.veno? || node.ajno?
        prev.tag = PosTag::Nform
        prev.val = prev.val.sub(" cái", "") if prev.key.ends_with?('个')
        node = prev.fold!(node)
      when .prodeics?
        node.tag = PosTag::Nform
        return fold_prodeic_noun!(prev, node)
      when .prointrs?
        val = prev.key == "什么" ? "gì đó" : prev.val
        return node.fold_left!(prev, "#{node.val} #{val}")
      when .amorp? then node = node.fold_left!(prev)
      when .place?, .adesc?, .ahao?, .ajno?, .modifier?, .modiform?
        node = node.fold_left!(prev, "#{node.val} #{prev.val}")
      when .ajav?, .adjt?
        break if prev.key.size > 1
        node = node.fold_left!(prev, "#{node.val} #{prev.val}")
      when .ude1?
        break if mode < 1
        node = fold_ude1!(node, prev)
        break if node.prev? == prev
      else
        break
      end

      node.tag = PosTag::Nform
    end

    node
  end
end

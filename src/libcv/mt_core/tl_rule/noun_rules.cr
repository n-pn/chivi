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
        node.fold!(succ)
      when .names?
        break unless node.names?
        node.tag = succ.tag
        node.fold!(succ)
      when .place?
        node.tag = PosTag::Noun
        node.fold!(succ, "#{succ.val} #{node.val}")
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
        else break
        end
      when .concoord?
        node = fold_concoord!(node, succ, succ.succ?)
        break if node.succ == succ
      when .penum?
        node = fold_penum!(node, succ, succ.succ?)
        break if node.succ == succ
      when .suf_verb?
        node = fold_suf_verb!(node, succ)
        break
      when .suf_nouns?
        node = fold_suf_noun!(node, succ)
        break
      else break
      end
    end

    node
  end

  def fold_noun_space!(node : MtNode, succ = node.succ?) : MtNode
    return node unless succ
    node.tag = PosTag::Place

    # if (prev = node.prev?) && prev.nquant?
    #   prev.val = "#{succ.val} #{prev.val} #{node.val}"
    #   prev.dic = 7
    #   node = prev.fold_many!(node, succ)
    # else

    case succ.key
    when "上"
      node.fold!("trên #{node.val}")
    when "下"
      node.fold!("dưới #{node.val}")
    when "之前"
      node.fold!("trước #{node.val}")
    else
      node.fold!("#{succ.val} #{node.val}")
    end
  end

  def heal_veno!(node : MtNode)
    return node.heal!(tag: PosTag::Noun) unless succ = node.succ?

    case succ
    when .puncts?, .suf_nouns?
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
end

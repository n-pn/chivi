require "./tl_rule/*"

module CV::TlRule
  def fix_grammar!(node : MtNode, mode = 1)
    while node = node.succ?
      case node.tag
      when .ude1?     then node = heal_ude1!(node, mode: mode) # 的
      when .ule?      then node = fix_ule!(node)               # 了
      when .ude2?     then node = fix_ude2!(node)              # 地
      when .urlstr?   then node = fold_urlstr!(node)
      when .string?   then node = fold_string!(node)
      when .preposes? then node = fold_preposes!(node)
      when .pronouns? then node = fold_pronouns!(node)
      when .numbers? # , .quantis?
        node = fold_number!(node)
        node = fold_noun_left!(node) if node.nquants? && !node.succ?(&.nouns?)
      when .vshi?    then next # TODO handle vshi
      when .vyou?    then next # TODO handle vyou
      when .vmodals? then node = heal_vmodal!(node)
      when .verbs?   then node = fold_verbs!(node)
      when .adjts?
        node = fold_adjts!(node, prev: nil)
        next unless node.nouns?
        node = fold_noun_left!(node, mode: mode)
      when .adverbs?
        node = fold_adverbs!(node)
      when .nouns?
        node = fold_noun!(node)
        next unless node.nouns?
        node = fold_noun_left!(node, mode: mode)
      when .space?
        if node.prev.noun?
          node = fold_noun_space!(node.prev, node)
        else
          node = fold_noun_left!(node, mode: mode)
        end
      when .special?
        node = fix_by_key!(node)
      end
    end

    self
  rescue err
    self
  end

  private def fix_by_key!(node : MtNode, succ = node.succ?) : MtNode
    case node.key
    when "对不起"
      boundary?(succ) ? node : fold_verbs!(node.heal!("có lỗi với", PosTag::Verb))
    when "原来"
      if succ.try(&.ude1?) || node.prev?(&.contws?)
        node.heal!("ban đầu", tag: PosTag::Modifier)
      else
        node.heal!("thì ra")
      end
    when "行"
      boundary?(succ) ? node.heal!("được") : node
    when "高达"
      if succ.try(&.nquants?)
        node.heal!("cao đến")
      else
        node.heal!(tag: PosTag::Noun)
      end
    else
      node
    end
  end

  private def fix_quoteop!(node : MtNode)
    return node unless succ = node.succ?
    return node unless succ_2 = succ.succ?
    return node unless succ_2.quotecl?

    node.dic = 6
    node.tag = succ.tag
    note.val = "#{node.val}#{succ.val}#{succ_2.val}"
    node.fold_many!(succ, succ_2)
  end

  def fix_ule!(node : MtNode) : MtNode
    return node unless (prev = node.prev?) && (succ = node.succ?)

    return node.heal!(val: "") if succ.tag.quoteop? || prev.tag.quotecl?
    return node.heal!(val: "") if prev.tag.quotecl? && !succ.tag.ends?

    return node if succ.tag.ends? || prev.tag.ends? || succ.key == prev.key
    return node if prev.tag.adjts? && prev.prev?(&.tag.ends?)

    node.heal!(val: "")
  end

  def fix_ude2!(node : MtNode) : MtNode
    return node if node.prev? { |x| x.tag.adjts? || x.tag.adverb? }
    return node if node.succ? { |x| x.verbs? || x.preposes? || x.concoord? }
    node.heal!(val: "địa", tag: PosTag::Noun)
  end
end

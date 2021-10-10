require "./grammars/*"
require "../tl_rule/*"

module CV::MTL::Grammars
  def fix_grammar!(node : MtNode = @head, mode = 1)
    while node = node.succ?
      case node.tag
      when .ude1?     then node = fix_ude1!(node, mode: mode) # 的
      when .ule?      then node = fix_ule!(node)              # 了
      when .ude2?     then node = fix_ude2!(node)             # 地
      when .urlstr?   then node = TlRule.fold_urlstr!(node)
      when .string?   then node = TlRule.fold_string!(node)
      when .preposes? then node = TlRule.fold_preposes!(node)
      when .pronouns? then node = TlRule.fold_pronouns!(node)
      when .numbers? # , .quantis?
        node = TlRule.fold_number!(node)
        node = fix_nouns!(node) if node.nquants? && !node.succ?(&.nouns?)
      when .vshi?    then next # TODO handle vshi
      when .vyou?    then next # TODO handle vyou
      when .vmodals? then node = TlRule.heal_vmodal!(node)
      when .verbs?   then node = TlRule.fold_verbs!(node)
      when .adjts?
        node = TlRule.fold_adjts!(node, prev: nil)
        return node unless node.nouns?
        node = fix_nouns!(node, mode: mode)
      when .adverbs?
        node = TlRule.fold_adverbs!(node)
      when .nouns?
        node = TlRule.fold_noun!(node)
        next unless node.nouns?
        node = fix_nouns!(node, mode: mode)
      when .space?
        if node.prev.noun?
          node = TlRule.fold_noun_space!(node.prev, node)
        else
          node = fix_nouns!(node, mode: mode)
        end
      when .special?
        node = fix_by_key!(node)
      end
    end

    self
  rescue err
    self
  end

  private def boundary?(node : Nil)
    true
  end

  private def boundary?(node : MtNode)
    node == @head || node.tag.puncts? || node.tag.interjection?
  end

  private def fix_by_key!(node : MtNode, succ = node.succ?) : MtNode
    case node.key
    when "对不起"
      boundary?(succ) ? node : TlRule.fold_verbs!(node.heal!("có lỗi với", PosTag::Verb))
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
end

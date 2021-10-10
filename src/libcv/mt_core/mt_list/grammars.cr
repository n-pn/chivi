require "./grammars/*"
require "../tl_rule/*"

module CV::MTL::Grammars
  def fix_grammar!(node : MtNode = @head, mode = 1)
    while node = node.succ?
      case node.tag
      when .ude1?   then node = fix_ude1!(node, mode: mode) # 的
      when .ule?    then node = fix_ule!(node)              # 了
      when .ude2?   then node = fix_ude2!(node)             # 地
      when .urlstr? then node = TlRule.fold_urlstr!(node)
      when .string? then node = TlRule.fold_string!(node)
      when .predui? then node = TlRule.heal_predui!(node)
      when .numbers? # , .quantis?
        node = fix_number!(node)
        node = fix_nouns!(node) if node.nquants? && !node.succ?(&.nouns?)
      when .numlat?  then node = fix_number!(node)
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
      else
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

  private def fix_by_key!(node : MtNode) : MtNode
    case node.key
    when "原来"
      if node.succ?(&.ude1?) || node.prev?(&.contws?)
        val = "ban đầu"
      else
        val = "thì ra"
      end
      node.heal!(val)
    when "行"
      node.heal!("được") if boundary?(node.succ?)
    when "高达"
      node.heal!("cao đến") if node.succ?(&.nquants?)
    end

    node
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

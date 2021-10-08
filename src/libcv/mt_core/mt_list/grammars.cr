require "./grammars/*"
require "../tl_rule/*"

module CV::MTL::Grammars
  def fix_grammar!(node = @head, mode = 2)
    while node = node.succ?
      case node.tag
      when .ude1?    then node = fix_ude1!(node, mode: mode) # 的
      when .ule?     then node = fix_ule!(node)              # 了
      when .ude2?    then node = fix_ude2!(node)             # 地
      when .urlstr?  then node = TlRule.fold_urlstr!(node)
      when .string?  then node = TlRule.fold_string!(node)
      when .quoteop? then node = fix_quoteop(node)
      when .numbers? # , .quantis?
        node = fix_number!(node)
        node = fix_nouns!(node) if node.nquants? && !node.succ?(&.nouns?)
      when .numlat?  then node = fix_number!(node)
      when .vshi?    then next # TODO handle vshi
      when .vyou?    then next # TODO handle vyou
      when .vmodals? then node = TlRule.heal_vmodal!(node)
      when .verbs?   then node = TlRule.fold_verbs!(node)
      when .adjts?   then node = fix_adjts!(node, mode: mode)
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
end

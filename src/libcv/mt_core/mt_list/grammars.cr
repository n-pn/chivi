require "./grammars/*"

module CV::MTL::Grammars
  def fix_grammar!(node = @head, mode = 2)
    while node = node.succ?
      case node.tag
      when .ude1?    then node = fix_ude1!(node, mode: mode) # 的
      when .ule?     then node = fix_ule!(node)              # 了
      when .ude2?    then node = fix_ude2!(node)             # 地
      when .urlstr?  then node.fix_urlstr
      when .string?  then node.fix_string
      when .quoteop? then node = fix_quoteop(node)
      when .number?  then node = fix_number!(node)
      when .numlat?  then node = fix_number!(node)
      when .vxiang?  then node = fix_vxiang!(node)
      when .vshi?    then next # TODO handle vshi
      when .vyou?    then next # TODO handle vyou
      when .verbs?   then node = fix_verbs!(node, mode: mode)
      when .adjts?   then node = fix_adjts!(node, mode: mode)
      when .nouns?   then node = fix_nouns!(node, mode: mode)
      else                fix_by_key!(node)
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

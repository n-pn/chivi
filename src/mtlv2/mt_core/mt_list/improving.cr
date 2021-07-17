require "./improving/*"

module CV::Improving
  def fix_grammar!(node = @root)
    while node = node.succ
      case node.tag
      when .ude1?   then node.update!(val: "")  # 的
      when .ule?    then node = fix_ule!(node)  # 了
      when .ude2?   then ndoe = fix_ude2!(node) # 地
      when .string? then node = fix_string!(node)
      when .number? then node = fix_number!(node)
      when .vxiang? then node = fix_vxiang!(node)
      when .verbs?  then node = fix_verbs!(node)
      when .adjts?  then node = fix_adjts!(node)
      when .nouns?  then node = fix_nouns!(node)
      else               fix_by_key!(node)
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
    node.tag.puncts? || node.tag.interjection?
  end
end

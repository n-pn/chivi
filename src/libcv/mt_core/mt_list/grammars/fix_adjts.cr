module CV::MTL::Grammars
  def fix_adjts!(node = @head, mode = 1) : MtNode
    node = TlRule.fold_adjts!(node, prev: nil)
    return node unless node.nouns?
    fix_nouns!(node, mode: 1)
  end

  # private def fix_adjts!(node = @head)
  #   while node = node.succ
  #     next unless node.adjts?

  #     prev = node.prev.not_nil!
  #     skip, left, right = false, "", ""

  #     case prev.key
  #     when "不", "很", "太", "多", "未", "更", "级", "超"
  #       skip, left = true, "#{prev.val} "
  #     when "最", "那么", "这么", "非常",
  #          "很大", "如此", "极为"
  #       skip, right = true, " #{prev.val}"
  #     when "不太"
  #       skip, left, right = true, "không ", " lắm"
  #       # else
  #       # skip, left = true, "#{prev.val} " if prev.cat == 4
  #     end
  #   end

  #   self
  # end
end

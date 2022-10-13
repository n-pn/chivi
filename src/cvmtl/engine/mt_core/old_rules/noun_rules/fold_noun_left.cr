module MT::TlRule
  # def fold_noun_left!(node : BaseNode, mode = 1)
  #   flag = 0

  #   while prev = node.prev?
  #     case prev
  #     when .numeral?
  #       break if node.pl_veno? || node.pl_ajno?
  #       node = fold_nquant_noun!(prev, node)
  #       flag = 1
  #     when .pro_ji?
  #       return fold!(prev, node, MapTag::Nform)
  #     when .pro_ints?
  #       return fold_什么_noun!(prev, node) if prev.key == "什么"
  #       return fold_flip!(prev, node, MapTag::Nform)
  #     when .pl_ajno?, .amod_words?
  #       break if flag > 0
  #       node = fold_flip!(prev, node, MapTag::Nform)
  #     when .position?
  #       break if flag > 0
  #       node = fold_flip!(prev, node, MapTag::Nform)
  #     when .pl_ajad?, .adjt_words?
  #       break if flag > 0 || prev.key.size > 1
  #       node = fold_flip!(prev, node, MapTag::Nform)
  #     when .pt_dep?
  #       break if mode < 1
  #       node = fold_ude1_left!(ude1: node, left: prev, right: ude1.succ?)
  #     else
  #       break
  #     end

  #     break if prev == node.prev?
  #   end

  #   node
  # end

  def fold_什么_noun!(prev : BaseNode, node : BaseNode)
    succ = MonoNode.new("么", "gì", prev.tag, 1, prev.idx + 1)

    prev.key = "什"
    prev.val = "cái"

    succ.fix_succ!(node.succ?)
    node.fix_succ!(succ)

    fold!(prev, succ, MapTag::Nform)
  end
end

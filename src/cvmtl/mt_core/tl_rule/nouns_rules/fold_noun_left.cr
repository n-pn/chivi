module CV::TlRule
  def fold_nquant_noun!(prev : MtNode, node : MtNode)
    prev = clean_个!(prev)
    node = fold!(prev, node, PosTag::NounPhrase, dic: 3)
    node
  end

  def fold_noun_left!(node : MtNode, mode = 1)
    flag = 0

    while prev = node.prev?
      case prev
      when .numeric?
        break if node.veno? || node.ajno?
        node = fold_nquant_noun!(prev, node)
        flag = 1
      when .pro_ji?
        return fold!(prev, node, PosTag::NounPhrase, dic: 3)
      when .pro_ints?
        return fold_什么_noun!(prev, node) if prev.key == "什么"
        return fold_swap!(prev, node, PosTag::NounPhrase, dic: 3)
      when .amorp?
        break if flag > 0
        node = fold!(prev, node, PosTag::NounPhrase, dic: 7)
      when .ajno?, .modifier?
        break if flag > 0
        node = fold_swap!(prev, node, PosTag::NounPhrase, dic: 3)
      when .place?
        break if flag > 0
        node = fold_swap!(prev, node, PosTag::NounPhrase, dic: 3)
      when .ajad?, .adjts?
        break if flag > 0 || prev.key.size > 1
        node = fold_swap!(prev, node, PosTag::NounPhrase, dic: 8)
      when .ude1?
        break if mode < 1
        node = fold_ude1!(node, prev)
      else
        break
      end

      break if prev == node.prev?
    end

    node
  end

  def fold_什么_noun!(prev : MtNode, node : MtNode)
    succ = MtNode.new("么", "gì", prev.tag, 1, prev.idx + 1)

    prev.key = "什"
    prev.val = "cái"

    succ.fix_succ!(node.succ?)
    node.fix_succ!(succ)

    fold!(prev, succ, PosTag::NounPhrase, dic: 3)
  end
end

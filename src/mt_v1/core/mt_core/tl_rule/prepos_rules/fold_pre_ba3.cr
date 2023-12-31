module M1::TlRule
  def fold_pre_ba3!(node : MtNode, succ = node.succ?, mode = 0) : MtNode
    return fold_prepos_inner!(node, succ, mode: mode) unless pre_ba3_is_qtnoun?(node, succ)
    return node unless noun = scan_noun!(succ)

    node.set!(guess_pre_ba3_defn(noun) || "chiếc", PosTag::Qtnoun)
    fold!(node, noun, noun.tag, dic: 5)
  end

  BA3_HANDLERS = {'剑', '刀', '枪'}

  def guess_pre_ba3_defn(noun : MtDefn) : String?
    noun.key.each_char do |char|
      return "thanh" if BA3_HANDLERS.includes?(char)
      return "nắm" if BA3_IN_HANDS.includes?(char)
    end
  end

  BA3_IN_HANDS = {'米', '花', '盐', '糖', '麦', '谷'}

  def guess_pre_ba3_defn(noun : MtNode) : String?
    noun.each do |node|
      guess_pre_ba3_defn(node).try { |x| return x }
    end
  end

  def pre_ba3_is_qtnoun?(node : MtNode, succ = node.succ?)
    return false unless prev = node.prev?
    return true if prev.numbers? || prev.v_shi? || prev.pro_ji?
    return false unless prev.pro_na1? || prev.pro_zhe?
    true
    # TODO: handle more cases
  end
end

module MtlV2::TlRule
  def fold_pre_ba3!(node : BaseNode, succ = node.succ?) : BaseNode
    return fold_prepos_inner!(node, succ) unless pre_ba3_is_qtnoun?(node, succ)
    return node unless noun = scan_noun!(succ)

    node.set!(guess_pre_ba3_defn(noun) || "chiếc", PosTag::Qtnoun)
    fold!(node, noun, noun.tag, dic: 5)
  end

  BA3_HANDLERS = {'剑', '刀', '枪'}
  BA3_IN_HANDS = {'米', '花', '盐', '糖', '麦', '谷'}

  def guess_pre_ba3_defn(noun : BaseNode) : String?
    noun.each do |x|
      if body = noun.body?
        if y = guess_pre_ba3_defn(body)
          next y
        end
      else
        x.key.each_char do |char|
          next "thanh" if BA3_HANDLERS.includes?(char)
          next "nắm" if BA3_IN_HANDS.includes?(char)
        end
      end
    end
  end

  def pre_ba3_is_qtnoun?(node : BaseNode, succ = node.succ?)
    return false unless prev = node.prev?
    return true if prev.numbers? || prev.v_shi? || prev.pro_ji?
    return false unless prev.pro_na1? || prev.pro_zhe?
    true
    # TODO: handle more cases
  end
end

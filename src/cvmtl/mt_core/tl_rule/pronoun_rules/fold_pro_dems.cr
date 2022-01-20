module CV::TlRule
  def fold_pro_dems!(node : MtNode, succ : MtNode) : MtNode
    return node if node.key == "这儿" || node.key == "那儿"
    return heal_pro_dem!(node) if succ.key.in?({"就"})

    if succ.pro_ji? && (tail = succ.succ?)
      if tail.nhanzi?
        succ = fold_proji_nhanzi!(succ, tail)
        return fold_prodem_nounish!(node, succ)
      else
        tail = heal_quanti!(tail)
        succ = fold!(succ, tail, PosTag::Nqnoun, dic: 6) if tail.quantis?
      end
    elsif node.pro_ji? && succ.nhanzi?
      return fold_proji_nhanzi!(node, succ)
    end

    node, quanti, succ = split_prodem!(node)
    # puts [node, quanti, succ]

    if succ && !(succ.pro_dems? || succ.v_shi? || succ.v_you?)
      return scan_noun!(succ, prodem: node, nquant: quanti).not_nil!
    end

    return heal_pro_dem!(node) unless quanti
    fold!(node, quanti, PosTag::ProDem, dic: 8, flip: true)
  end

  def fold_proji_nhanzi!(node : MtNode, succ : MtNode)
    succ.val = succ.val.sub("mười", "chục")
    node = fold!(node, succ, PosTag::Number, dic: 5)
    scan_noun!(node.succ?, nquant: node).not_nil!
  end

  def split_prodem!(node : MtNode?, succ : MtNode? = node.succ?)
    if succ && !node.pro_dem? # is pro_zhe, pro_na1, pro_ji
      succ = heal_quanti!(succ)
      return succ.quantis? ? {node, succ, succ.succ?} : {node, nil, succ}
    end

    if (left = node.body?) && (right = left.succ?)
      if right.pro_dems?
        # flip back if swapped before
        right.fix_prev!(node.prev?)
        left.fix_succ!(node.succ?)
        right.fix_succ!(left)
        return {right, left, succ}
      else
        left.fix_prev!(node.prev?)
        right.fix_succ!(node.succ?)
        return {left, right, succ}
      end
    end

    unless match = node.key.match(/^(这|那)(.*[^儿])$/)
      return {node, nil, succ}
    end

    _, node.key, qt_key = match
    node.tag, pro_val = map_pro_dem!(node.key)
    return {node, nil, succ} if pro_val.empty?

    qt_val = node.val.sub(" " + pro_val, "")
    node.val = pro_val

    qtnoun = MtNode.new(qt_key, qt_val, PosTag::Qtnoun, 1, node.idx + 1)

    node.set_succ!(qtnoun)
    {node, qtnoun, succ}
  end

  def map_pro_dem!(key : String) : {PosTag, String}
    case key
    when "这" then {PosTag::ProZhe, "này"}
    when "那" then {PosTag::ProNa1, "kia"}
      # when '几' then {PosTag::ProJi, "mấy"}
    else {PosTag::ProDem, ""}
    end
  end
end
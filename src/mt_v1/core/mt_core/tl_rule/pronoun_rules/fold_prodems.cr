module M1::TlRule
  # ameba:disable Metrics/CyclomaticComplexity
  def fold_pro_dems!(node : MtNode, succ : MtNode) : MtNode
    return node if node.key == "这儿" || node.key == "那儿"
    return heal_pro_dem!(node) if succ.key.in?({"就"})

    if succ.pro_ji? && (tail = succ.succ?)
      if tail.nhanzi?
        succ = fold_proji_nhanzi!(succ, tail)
        return fold_prodem_nominal!(node, succ)
      elsif node.pro_zhe? || node.pro_na1? || node.pro_na2?
        tail = heal_quanti!(tail)

        case tail.tag
        when .qttime?
          tag = PosTag::Nqtime
        when .qtnoun?
          tag = PosTag::Nqtime
        when .qtverb?
          tag = PosTag::Nqverb
        end

        if tag
          succ = fold!(succ, tail, tag, dic: 6)
          return scan_noun!(succ.succ?, prodem: node, nquant: succ) || node
        else
          return scan_noun!(succ, prodem: node, nquant: nil) || node
        end
      end
    elsif node.pro_ji? && succ.nhanzi?
      return fold_proji_nhanzi!(node, succ)
    end

    node, quanti, succ = split_prodem!(node)

    if succ && !(succ.pro_dems? || succ.v_shi? || succ.v_you?)
      return scan_noun!(succ, prodem: node, nquant: quanti).not_nil!
    end

    return heal_pro_dem!(node) unless quanti
    fold_prodem_nominal!(node, quanti)
  end

  def fold_proji_nhanzi!(node : MtNode, succ : MtNode)
    succ.val = succ.val.sub("mười", "chục")
    node = fold!(node, succ, PosTag::Number, dic: 4)
    fold_proji_right!(node)
  end

  def fold_proji_right!(node : MtNode)
    return node unless tail = node.succ?
    tail = heal_quanti!(tail)

    case tail.tag
    when .qttime? then tag = PosTag::Nqtime
    when .qtnoun? then tag = PosTag::Nqtime
    when .qtverb? then tag = PosTag::Nqverb
    end

    if tag
      node = fold!(node, tail, tag, dic: 6)
      tail = node.succ?
    end

    scan_noun!(tail, prodem: nil, nquant: node) || node
  end

  def prodem_shoud_split?(node : MtNode)
    return true unless node.pro_dem? # is pro_zhe, pro_na1, pro_ji...
    node.key == "此"
  end

  def split_prodem!(node : MtNode, succ : MtNode? = node.succ?)
    if succ && prodem_shoud_split?(node)
      succ = heal_quanti!(succ)
      return succ.quantis? ? {node, succ, succ.succ?} : {node, nil, succ}
    end

    if node.is_a?(MtList)
      left = node.list.first
      right = node.list.last

      if right.pronouns?
        # flip back if swapped before
        left.fix_succ!(node.succ?)
        right.fix_prev!(node.prev?)
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

    qtnoun = MtDefn.new(qt_key, qt_val, PosTag::Qtnoun, 1, node.idx + 1)
    qtnoun.fix_succ!(succ)
    node.fix_succ!(qtnoun)

    {node, qtnoun, succ}
  end

  def map_pro_dem!(key : String) : {PosTag, String}
    case key
    when "这" then {PosTag::ProZhe, "này"}
    when "那" then {PosTag::ProNa1, "kia"}
    when "几" then {PosTag::ProJi, "mấy"}
    else          {PosTag::ProDem, ""}
    end
  end
end

module CV::TlRule
  def fold_pro_dems!(node : MtNode, succ : MtNode) : MtNode
    # if node.key == "这儿" || node.key == "这儿"
    #   succ = fold_noun!(succ) if succ.nouns?
    #   return node
    # end

    if node.pro_ji? && succ.nhanzi?
      succ.val = succ.val.sub("mười", "chục")
      node = fold!(node, succ, PosTag::Number, dic: 5)

      return scan_noun!(node.succ?, nquant: node).not_nil!
    end

    node, quanti, succ = split_prodem!(node)
    # puts [node, quanti, succ]

    if succ && !(succ.pro_dems? || succ.v_shi? || succ.v_you?)
      return scan_noun!(succ, prodem: node, nquant: quanti).not_nil!
    end

    return fold!(node, quanti, PosTag::ProDem, dic: 8, flip: true) if quanti

    return node.set!("cái này") if node.pro_zhe?
    return node.set!("vậy") if node.pro_na1? && !node.succ?(&.maybe_verb?)

    node
  end

  def fold_prodem_nounish!(prodem : MtNode?, nounish : MtNode?)
    return nounish unless prodem

    if nounish
      flip = !nounish.time? && should_flip_prodem?(prodem)
      return fold!(prodem, nounish, PosTag::NounPhrase, dic: 2, flip: flip)
    end

    return prodem.set!("cái này") if prodem.pro_zhe?
    return prodem.set!("vậy") if prodem.pro_na1? && !prodem.succ?(&.maybe_verb?)
    prodem
  end

  def should_flip_prodem?(prodem : MtNode)
    return true if prodem.pro_zhe? || prodem.pro_na1?
    {"另"}.includes?(prodem.key)
  end

  def split_prodem!(node : MtNode?, succ : MtNode? = node.succ?)
    if succ && !node.pro_dem? # is pro_zhe, pro_na1, pro_ji

      succ = heal_quanti!(succ)

      return succ.quantis? ? {node, succ, succ.succ?} : {node, nil, succ}
    end

    if (qtnoun = node.body?) && (prodem = qtnoun.succ?)
      # flip back

      prodem.fix_prev!(node.prev?)
      qtnoun.fix_succ!(node.succ?)
      prodem.fix_succ!(qtnoun)

      return {prodem, qtnoun, succ}
    end

    if node.key.size < 2 || node.key == "这儿" || node.key == "这儿"
      return {node, nil, succ}
    end

    node.key, qt_key = node.key.split("", 2)
    node.tag, pro_val = map_pro_dem!(node.key)
    return {node, nil, succ} if pro_val.empty?

    qt_val = node.val.sub(" " + pro_val, "")
    node.val = pro_val

    qtnoun = MtNode.new(qt_key, qt_val, PosTag::Qtnoun, 1, node.idx + 1)

    node.set_succ!(qtnoun)
    {node, qtnoun, succ}
  end

  # FIX_PRONOUNS = {
  #   "这" => "này",
  #   "那" => "kia",
  #   "这个" => "kia",
  #   "那个" => "kia",
  #   "这样" => "như vậy",
  #   "那样" => "như thế",
  # }

  # def split_pro_dem!(node : MtNode) : Tuple(MtNode, MtNode?)
  #   if qtnoun = node.body?
  #     prodem = qtnoun.succ

  #     # flip back

  #     prodem.fix_prev!(node.prev?)
  #     qtnoun.fix_succ!(node.succ?)
  #     prodem.fix_succ!(qtnoun)

  #     return {prodem, qtnoun}
  #   end

  #   if node.key.size < 2 || node.key == "这儿" || node.key == "这儿"
  #     return {node, nil}
  #   end

  #   node.key, qt_key = node.key.split("", 2)

  #   node.tag, pro_val = map_pro_dem!(node.key)
  #   return {node, nil} if pro_val.empty?

  #   qt_val = node.val.sub(" " + pro_val, "")
  #   node.val = pro_val

  #   qtnoun = MtNode.new(qt_key, qt_val, PosTag::Qtnoun, 1, node.idx + 1)

  #   prodem = node
  #   prodem.set_succ!(qtnoun)

  #   {prodem, qtnoun}
  # end

  def map_pro_dem!(key : String) : {PosTag, String}
    case key
    when "这" then {PosTag::ProZhe, "này"}
    when "那" then {PosTag::ProNa1, "kia"}
      # when '几' then {PosTag::ProJi, "mấy"}
    else {PosTag::ProDem, ""}
    end
  end
end

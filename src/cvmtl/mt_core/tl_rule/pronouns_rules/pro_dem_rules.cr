module CV::TlRule
  def fold_pro_dems!(node : MtNode, succ : MtNode) : MtNode
    case node
    when .pro_zhe?, .pro_na1?, .pro_ji?
      succ = heal_quanti!(succ)
      if succ.quantis?
        quanti = succ
        succ = quanti.succ?
      end
    else
      node, quanti = split_pro_dem!(node) if node.key.size > 1
    end

    if succ && !(succ.pro_dems? || succ.v_shi? || succ.v_you?)
      scan_noun!(succ, mode: 1) do |succ|
        if quanti
          case quanti.key
          when "些" then quanti.val = "những"
          when "个" then quanti.val = ""
          end
          succ = fold!(quanti, succ, succ.tag, dic: 4)
        end

        flip = !succ.time? && node.pro_zhe? || node.pro_na1?
        return fold!(node, succ, PosTag::NounPhrase, dic: 2, flip: flip)
      end
    end

    return fold!(node, quanti, PosTag::ProDem, dic: 8, flip: true) if quanti

    return node.set!("cái này") if node.pro_zhe?
    return node.set!("vậy") if node.pro_na1? && !node.succ?(&.maybe_verb?)

    node
  end

  def fold_pro_dem_noun!(node : MtNode, succ : MtNode?)
    if (succ = node.succ?) && !succ.pro_dem?
      succ = scan_noun!(succ, prev: node)
      node = succ if succ.nouns?
    end
  end

  # FIX_PRONOUNS = {
  #   "这" => "này",
  #   "那" => "kia",
  #   "这个" => "kia",
  #   "那个" => "kia",
  #   "这样" => "như vậy",
  #   "那样" => "như thế",
  # }

  def split_pro_dem!(node : MtNode) : Tuple(MtNode, MtNode?)
    if qtnoun = node.body?
      prodem = qtnoun.succ

      # flip back

      prodem.fix_prev!(node.prev?)
      qtnoun.fix_succ!(node.succ?)
      prodem.fix_succ!(qtnoun)

      # puts prodem.prev?(&.succ?) == prodem
      # puts qtnoun.succ?(&.prev?) == qtnoun
    else
      node.key, qt_key = node.key.split("", 2)
      node.tag, pro_val = map_pro_dem!(node.key)
      return {node, nil} if pro_val.empty?

      qt_val = node.val.sub(" " + pro_val, "")
      node.val = pro_val

      qtnoun = MtNode.new(qt_key, qt_val, PosTag::Qtnoun, 1, node.idx + 1)

      prodem = node
      prodem.set_succ!(qtnoun)

      # puts prodem.prev?(&.succ?) == prodem
      # puts qtnoun.succ?(&.prev?) == qtnoun
    end

    {prodem, qtnoun}
  end

  def self.map_pro_dem!(key : String) : {PosTag, String}
    case key
    when "这" then {PosTag::ProZhe, "này"}
    when "那" then {PosTag::ProNa1, "kia"}
      # when '几' then {PosTag::ProJi, "mấy"}
    else {PosTag::ProDem, ""}
    end
  end
end

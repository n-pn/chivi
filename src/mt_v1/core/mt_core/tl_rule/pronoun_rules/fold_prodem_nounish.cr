module M1::TlRule
  def fold_prodem_nominal!(prodem : MtNode?, nominal : MtNode?)
    return nominal unless prodem

    if nominal
      if nominal.verb_object?
        prodem = heal_pro_dem!(prodem)
        return fold!(prodem, nominal, PosTag::VerbClause, dic: 8)
      end

      # puts [prodem.prev?, prodem.succ?]
      # puts [nominal.prev?, nominal.succ?]

      flip = nominal.nominal? && should_flip_prodem?(prodem)
      tag = !prodem.pro_dem? && nominal.qtnoun? ? PosTag::ProDem : nominal.tag
      return fold!(prodem, nominal, tag, dic: 3, flip: flip)
    end

    heal_pro_dem!(prodem)
  end

  def should_flip_prodem?(prodem : MtNode)
    return false if prodem.pro_ji?
    return true unless prodem.pro_dem? # pro_ji, pro_na1, pro_na2
    {"另", "其他", "此", "某个", "某些"}.includes?(prodem.key)
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def heal_pro_dem!(pro_dem : MtNode) : MtNode
    case pro_dem
    when .pro_zhe?
      case succ = pro_dem.succ?
      when .nil?, .preposes?, MtList
        pro_dem.set!("cái này")
      when .verbal?
        pro_dem.set!("đây")
      when .comma?
        if (succ_2 = succ.succ?) && succ_2.pro_zhe? # && succ_2.succ?(&.maybe_verb?)
          pro_dem.set!("đây")
        else
          pro_dem.set!("cái này")
        end
      when .ends?
        pro_dem.set!("cái này")
      else
        if pro_dem.prev?(&.nominal?)
          pro_dem.set!("giờ")
        else
          pro_dem.set!("cái này")
        end
      end
    when .pro_na1?
      has_verb_after?(pro_dem) ? pro_dem : pro_dem.set!("vậy")
    else pro_dem
    end
  end
end

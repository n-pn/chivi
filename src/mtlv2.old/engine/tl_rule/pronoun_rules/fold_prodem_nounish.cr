module MtlV2::TlRule
  def fold_prodem_nominal!(prodem : Nil, nominal : Nil)
    nil
  end

  def fold_prodem_nominal!(prodem : Nil, nominal : BaseNode)
    nominal
  end

  def fold_prodem_nominal!(prodem : BaseNode, nominal : Nil)
    prodem
  end

  def fold_prodem_nominal!(prodem : BaseNode, nominal : BaseNode)
    # if nominal.verb_object?
    #   prodem = heal_pro_dem!(prodem)
    #   return fold!(prodem, nominal, PosTag::VerbClause, dic: 8)
    # end

    # puts [prodem.prev?, prodem.succ?]
    # puts [nominal.prev?, nominal.succ?]

    ptag = prodem.pro_dem? || !nominal.qtnoun? ? nominal.tag : PosTag::ProDem
    flip = should_flip_prodem?(prodem)

    noun = fold!(prodem, nominal, ptag, dic: 3, flip: flip)
    fold_noun_other!(noun)
  end

  def should_flip_prodem?(prodem : BaseNode)
    return false if prodem.pro_ji?
    return true unless prodem.pro_dem? # pro_ji, pro_na1, pro_na2
    {"另", "其他", "此", "某个", "某些"}.includes?(prodem.key)
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def heal_pro_dem!(pro_dem : BaseNode) : BaseNode
    case pro_dem
    when .pro_zhe?
      case succ = pro_dem.succ?
      when .nil?, .preposes?, .body?
        pro_dem.set!("cái này")
      when .verb_words?
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
        if pro_dem.prev?(&.noun_words?)
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

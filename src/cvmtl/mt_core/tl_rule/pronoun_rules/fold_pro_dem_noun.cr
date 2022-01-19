module CV::TlRule
  def fold_prodem_nounish!(prodem : MtNode?, nounish : MtNode?)
    return nounish unless prodem

    if nounish
      if nounish.verb_object?
        prodem = heal_pro_dem!(prodem)
        return fold!(prodem, nounish, PosTag::VerbClause, dic: 8)
      end

      # puts [prodem.prev?, prodem.succ?]
      # puts [nounish.prev?, nounish.succ?]

      flip = nounish.nouns? && should_flip_prodem?(prodem)
      tag = !prodem.pro_dem? && nounish.qtnoun? ? PosTag::ProDem : nounish.tag
      return fold!(prodem, nounish, tag, dic: 2, flip: flip)
    end

    heal_pro_dem!(prodem)
  end

  def should_flip_prodem?(prodem : MtNode)
    return true if prodem.pro_zhe? || prodem.pro_na1?

    {"另", "其他", "此", "某个", "某些"}.includes?(prodem.key)
  end

  def heal_pro_dem!(pro_dem : MtNode) : MtNode
    case pro_dem
    when .pro_zhe?
      if (succ = pro_dem.succ?) && succ.comma?
        if succ.succ?(&.pro_zhe?) && has_verb_after?(succ.succ)
          return pro_dem.set!("đây")
        end
      elsif has_verb_after?(pro_dem)
        return pro_dem.set!(pro_dem.prev?(&.nouns?) ? "giờ" : "đây")
      end

      pro_dem.set!("cái này")
    when .pro_na1?
      has_verb_after?(pro_dem) ? pro_dem : pro_dem.set!("vậy")
    else pro_dem
    end
  end
end

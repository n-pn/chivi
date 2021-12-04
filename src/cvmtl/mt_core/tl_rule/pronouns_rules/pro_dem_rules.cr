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
      succ = scan_noun!(succ)

      if succ.nouns? || succ.nquants?
        if quanti
          case quanti.key
          when "些" then quanti.val = "những"
          when "个" then quanti.val = ""
          end
          succ = fold!(quanti, succ, succ.tag, dic: 4)
        end

        swap = node.pro_zhe? || node.pro_na1?
        return fold!(node, succ, PosTag::NounPhrase, dic: 2, swap: swap)
      end
    end

    return fold!(node, quanti, PosTag::ProDem, dic: 8, swap: true) if quanti

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

  def fold_pro_dem_noun!(prev : MtNode, node : MtNode)
    node.tag = PosTag::NounPhrase
    prev.val = prev.val.sub("cái", "").strip if prev.key.ends_with?("个")

    case prev.key
    when "各"
      prev.val = "các"
      fold!(prev, node, node.tag, dic: 2)
    when "这", "那", "这个", "那个"
      fold!(prev, node, node.tag, dic: 2, swap: true)
    when "这样"
      prev.val = "như vậy"
      fold!(prev, node, node.tag, dic: 2, swap: true)
    when "那样"
      prev.val = "như thế"
      fold!(prev, node, node.tag, dic: 2, swap: true)
    when "任何"
      prev.val = "bất kỳ"
      fold!(prev, node)
    when "其他"
      tail = MtNode.new("他", "khác", PosTag::ProPer, 1, prev.idx + 1)
      tail.fix_succ!(node.succ?)
      node.fix_succ!(tail)

      prev.key = "其"
      prev.val = "các"

      fold!(prev, tail, PosTag::NounPhrase, dic: 4)
    when .ends_with?("个")
      fold!(prev, node, node.tag, dic: 3)
    when .starts_with?("各")
      fold!(prev, node, node.tag, dic: 3)
    when .starts_with?("这"), .starts_with?("那")
      prodem, qtnoun = split_pro_dem!(prev)
      if qtnoun
        node.set_succ!(prodem)
        fold!(qtnoun, prodem, node.tag, dic: 3)
      else
        fold!(prev, node, node.tag, dic: 3)
      end
    else
      fold!(prev, node, node.tag, dic: 3, swap: true)
    end
  end

  def split_pro_dem!(node : MtNode) : Tuple(MtNode, MtNode?)
    if qtnoun = node.body?
      prodem = qtnoun.succ

      # swap back

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

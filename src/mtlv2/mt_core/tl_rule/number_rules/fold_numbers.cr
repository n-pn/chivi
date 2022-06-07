module CV::TlRule
  def fold_number!(node : MtNode, prev : MtNode? = nil)
    return node if !(succ = node.succ?) || succ.ends?

    if node.ndigit?
      node = fold_ndigit!(node, succ: succ, prev: prev)
      return fold_time_prev!(node, prev: prev) if node.temporal?
    elsif node.nhanzi?
      node = fold_nhanzi!(node, succ: succ, prev: prev)
      return fold_time_prev!(node, prev: prev) if node.temporal?
    end

    if node.numbers?
      node = fold_number_nquant!(node, prev: prev)
      return node unless node.numeral?
    end

    prodem = prev.try(&.pronouns?) ? prev : nil
    scan_noun!(node.succ?, prodem: prodem, nquant: node)

    # # puts ["number: ", node]
    # node = fuse_number!(node, prev: prev) # if head.numbers?

    # case node
    # when .temporal?
    #   # puts [node, node.succ?, node.prev?]
    #   node = fold_time_prev!(node, prev: prev) if prev && prev.temporal?

    #   if (prev = node.prev?) && prev.temporal?
    #     # TODO: do not do this but calling fold_number a second time instead
    #     node = fold!(prev, node, node.tag, dic: 6, flip: true)
    #   end

    #   fold_nouns!(node)
    # when .verbal?
    #   fold_verbs!(node)
    # when .noun?
    #   fold_nouns!(node)
    # else
    #   if (succ = node.succ?) && succ.uzhi?
    #     fold_uzhi!(succ, node)
    #   else
    #     # puts [node.succ?, node]
    #     scan_noun!(node.succ?, nquant: node) || node
    #   end
    # end
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def fold_number_nquant!(node : MtNode, prev : MtNode? = nil) : MtNode
    return node if !(tail = node.succ?) || tail.ends?

    return node if tail.puncts? && !tail.quantis?

    appro = 0
    # puts [node, tail]

    case tail
    when .pre_dui?
      if (succ_2 = tail.succ?) && succ_2.numbers?
        tail.val = "đối"
        return fold!(node, succ_2, PosTag::Aform, dic: 2)
      end

      tail.set!("đôi", PosTag::Qtnoun)
    when .pre_ba3?
      tail = fold_pre_ba3!(tail)

      if tail.nominal?
        return fold!(node, tail, tail.tag, dic: 3)
      elsif node.prev? { |x| x.verbal? || x.prev?(&.verbal?) }
        tail.set!("phát", PosTag::Qtverb)
        return fold!(node, tail, PosTag::Nqverb, dic: 5)
      else
        tail.set!("chiếc", PosTag::Qtnoun)
        return fold!(node, tail, PosTag::Nqnoun, dic: 5)
      end
    when .pro_ji?
      node = fold!(node, tail, PosTag::Number, dic: 5)

      # TODO: handle appros
      return fold_proji_right!(node)
    else
      if tail.key == "号"
        return fold!(node, tail, PosTag::Noun, dic: 9, flip: true)
      end

      node, appro = fold_pre_quanti_appro!(node, tail)
      if appro > 0
        return node unless tail = node.succ?
      end

      tail = heal_quanti!(tail)
      return fold_yi_verb!(node, tail) unless tail.quantis?
    end

    has_ge4 = tail if tail.key.ends_with?('个')

    node = fold!(node, tail, map_nqtype(tail), dic: 3)
    node = fold_suf_quanti_appro!(node) if has_ge4

    if has_ge4 && (tail = node.succ?) && tail.quantis?
      node = fold!(node, tail, map_nqtype(tail), dic: 3)
    end

    node = fold_suf_quanti_appro!(node)
    flag = MtFlag::Checked
    flag |= MtFlag::HasQtGe4 if has_ge4

    node.flag!(flag)
  end

  def map_nqtype(node : MtNode)
    case node.tag
    when .qtnoun? then PosTag::Nqnoun
    when .qttime? then PosTag::Nqtime
    when .qtverb? then PosTag::Nqverb
    else               PosTag::Nqiffy
    end
  end

  def fold_yi_verb!(node : MtNode, succ : MtNode)
    return node unless node.key == "一" && succ.verb? || succ.vintr?
    fold!(node.set!("vừa"), succ, succ.tag, dic: 4)
  end

  PRE_NUM_APPROS = {
    "近"  => "gần",
    "约"  => "chừng",
    "小于" => "ít hơn",
  }

  def is_pre_appro_num?(prev : MtNode?)
    return false unless prev
    PRE_NUM_APPROS.has_key?(prev.key)
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def meld_number!(node : MtNode)
    key_io = String::Builder.new(node.key)
    val_io = String::Builder.new(node.val)

    succ = node
    while succ = succ.try(&.succ?)
      if succ.ndigit? || succ.ndigit? # only combine if succ is hanzi or latin numbers
        node.tag = PosTag::Number
        key_io << succ.key
        val_io << " " << succ.val
        next
      end

      if node.nhanzi?
        break unless (succ_2 = succ.succ?) && succ_2.nhanzi?
        break unless succ.key == "点"
        break if succ_2.succ?(&.key.== "分")

        key_io << succ.key << succ_2.key
        val_io << " chấm " << succ_2.val
        succ = succ_2
        next
      end

      break unless node.ndigit? && (succ_2 = succ.succ?) && succ_2.ndigit?

      case succ.tag
      when .pdeci? # case 1.2
        key_io << succ.key << succ_2.key
        val_io << "." << succ_2.val
        succ = succ_2.succ?
      when .pdash? # case 3-4
        node.tag = PosTag::Number
        key_io << succ.key << succ_2.key
        val_io << "-" << succ_2.val
        succ = succ_2.succ?
      when .colon? # for 5:6 format

        node.tag = PosTag::Time
        key_io << succ.key << succ_2.key
        val_io << ":" << succ_2.val
        succ = succ_2.succ?

        # for 5:6:7 format
        break unless (succ_3 = succ_2.succ?) && succ_3.colon?
        break unless (succ_4 = succ_3.succ?) && succ_4.ndigit?

        key_io << succ_3.key << succ_4.key
        val_io << ":" << succ_4.val
        succ = succ_4.succ?
      end

      break
    end

    # TODO: correct translate unit system
    return node if succ == node.succ?

    node.key = key_io.to_s
    node.val = val_io.to_s

    node.fix_succ!(succ)
    node
  end
end

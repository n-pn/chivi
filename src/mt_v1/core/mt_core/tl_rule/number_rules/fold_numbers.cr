module M1::TlRule
  def fold_number!(node : MtNode, prev : MtNode? = nil)
    # puts ["number: ", node]
    node = fuse_number!(node, prev: prev) # if head.numbers?

    case node
    when .ntime?
      # puts [node, node.succ?, node.prev?]
      node = fold_time_prev!(node, prev: prev) if prev && prev.ntime?

      if (prev = node.prev?) && prev.ntime?
        # TODO: do not do this but calling fold_number a second time instead
        node = fold!(prev, node, node.tag, dic: 6, flip: true)
      end

      fold_nouns!(node)
    when .verbal?
      fold_verbs!(node)
    when .noun?
      fold_nouns!(node)
    else
      if (succ = node.succ?) && succ.uzhi?
        fold_uzhi!(succ, node)
      else
        scan_noun!(node.succ?, nquant: node) || node
      end
    end
  end

  def fold_nquant_noun!(prev : MtNode, node : MtNode)
    prev = clean_个!(prev)
    node = fold!(prev, node, PosTag::NounPhrase, dic: 3)
    node
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def fuse_number!(node : MtNode, prev : MtNode? = nil) : MtNode
    case node.tag
    when .ndigit?
      node = fold_ndigit!(node, prev: prev)
      return fold_time_appro!(node) if node.ntime?
    when .nhanzi?
      node = fold_nhanzi!(node, prev: prev)
      return fold_time_appro!(node) if node.ntime?
    when .quantis?, .nquants?
      # TODO: combine number with nquant?
      return node
    end

    return node unless node.numbers? && (tail = node.succ?)
    if tail.puncts?
      node = fold!(node, tail, PosTag::Nattr, dic: 5) if tail.quantis?
      return node
    end

    appro = 0

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
    appro = 1 if is_pre_appro_num?(node.prev?)

    case tail.key
    when "年" then node = fold_year!(node, tail, appro)
    when "月" then node = fold_month!(node, tail, appro)
    when "点" then node = fold_hour!(node, tail, appro)
    when "分" then node = fold_minute!(node, tail, appro)
    else
      node = fold!(node, tail, map_nqtype(tail), dic: 3)
      node = fold_suf_quanti_appro!(node) if has_ge4
    end

    if has_ge4 && (tail = node.succ?) && tail.quantis?
      heal_has_ge4!(has_ge4)
      node = fold!(node, tail, map_nqtype(tail), dic: 3)
    end

    fold_suf_quanti_appro!(node)
  end

  def map_nqtype(node : MtNode)
    case node.tag
    when .qtnoun? then PosTag::Nqnoun
    when .qttime? then PosTag::Nqtime
    when .qtverb? then PosTag::Nqverb
    else               PosTag::Nqiffy
    end
  end

  def heal_has_ge4!(node : MtNode)
    if node.key.size == 1
      node.val = ""
    else
      node.val = node.val.sub(" cái", "")
    end
  end

  def fold_yi_verb!(node : MtNode, succ : MtNode)
    return node unless node.key == "一" && (succ.verb? || succ.vintr?)
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

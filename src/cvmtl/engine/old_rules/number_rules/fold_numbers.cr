module MT::TlRule
  def fold_number!(node : MtNode, prev : MtNode? = nil)
    # puts ["number: ", node]
    node = fuse_number!(node, prev: prev) # if head.numbers?

    case node
    when .time_words?
      # puts [node, node.succ?, node.prev?]
      node = fold_time_prev!(node, prev: prev) if prev && prev.time_words?

      if (prev = node.prev?) && prev.time_words?
        # TODO: do not do this but calling fold_number a second time instead
        node = fold!(prev, node, node.tag, flip: true)
      end

      fold_nouns!(node)
    when .verbal_words?
      fold_verbs!(node)
    when .noun_words?
      fold_nouns!(node)
    else
      if (succ = node.succ?) && succ.ptcl_zhi?
        fold_uzhi!(succ, node)
      else
        scan_noun!(node.succ?, nquant: node) || node
      end
    end
  end

  def fold_nquant_noun!(prev : MtNode, node : MtNode)
    prev = clean_个!(prev)
    node = fold!(prev, node, MapTag::Nform)
    node
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def fuse_number!(node : MtNode, prev : MtNode? = nil) : MtNode
    case node.tag
    when .ndigits?
      node = fold_ndigit!(node, prev: prev)
      return fold_time_appro!(node) if node.time_words?
    when .nhanzis?
      node = fold_nhanzi!(node, prev: prev)
      return fold_time_appro!(node) if node.time_words?
    when .quantis?, .nquants?
      # TODO: combine number with nquant?
      return node
    end

    return node unless node.numbers? && (tail = node.succ?)
    if tail.punctuations?
      node = fold!(node, tail, MapTag::Nattr) if tail.quantis?
      return node
    end

    appro = 0

    # case tail
    # when .prep_dui?
    #   if (succ_2 = tail.succ?) && succ_2.numbers?
    #     tail.val = "đối"
    #     return fold!(node, succ_2, MapTag::Aform)
    #   end

    #   tail.set!("đôi", MapTag::Qtnoun)
    # when .prep_ba3?
    #   tail = fold_pre_ba3!(tail)

    #   if tail.noun_words?
    #     return fold!(node, tail, tail.tag)
    #   elsif node.prev? { |x| x.verbal? || x.prev?(&.verbal?) }
    #     tail.set!("phát", MapTag::Qtverb)
    #     return fold!(node, tail, MapTag::Nqverb)
    #   else
    #     tail.set!("chiếc", MapTag::Qtnoun)
    #     return fold!(node, tail, MapTag::Nqnoun)
    #   end
    # when .pro_ji?
    #   node = fold!(node, tail, MapTag::Numeric)

    #   # TODO: handle appros
    #   return fold_proji_right!(node)
    # else
    #   if tail.key == "号"
    #     return fold!(node, tail, MapTag::Noun, flip: true)
    #   end

    #   node, appro = fold_pre_quanti_appro!(node, tail)
    #   if appro > 0
    #     return node unless tail = node.succ?
    #   end

    #   tail = heal_quanti!(tail)
    #   return fold_yi_verb!(node, tail) unless tail.quantis?
    # end

    has_ge4 = tail if tail.key.ends_with?('个')
    appro = 1 if is_pre_appro_num?(node.prev?)

    case tail.key
    when "年" then node = fold_year!(node, tail, appro)
    when "月" then node = fold_month!(node, tail, appro)
    when "点" then node = fold_hour!(node, tail, appro)
    when "分" then node = fold_minute!(node, tail, appro)
    else
      node = fold!(node, tail, tail.tag.qt_to_nq!)
      node = fold_suf_quanti_appro!(node) if has_ge4
    end

    if has_ge4 && (tail = node.succ?) && tail.quantis?
      heal_has_ge4!(has_ge4)
      node = fold!(node, tail, tail.tag.qt_to_nq!)
    end

    fold_suf_quanti_appro!(node)
  end

  def heal_has_ge4!(node : MtNode)
    if node.key.size == 1
      node.val = ""
    else
      node.val = node.val.sub(" cái", "")
    end
  end

  def fold_yi_verb!(node : MtNode, succ : MtNode)
    return node unless node.key == "一" && succ.common_verbs?
    fold!(node.set!("vừa"), succ, succ.tag)
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
      if succ.ndigits? || succ.ndigits? # only combine if succ is hanzi or latin numbers
        node.tag = MapTag::Numeric
        key_io << succ.key
        val_io << " " << succ.val
        next
      end

      break unless node.nhanzis?
      break unless (succ_2 = succ.succ?) && succ_2.nhanzis?
      break unless succ.key == "点"
      break if succ_2.succ?(&.key.== "分")

      key_io << succ.key << succ_2.key
      val_io << " chấm " << succ_2.val
      succ = succ_2
    end

    # TODO: correct translate unit system
    return node if succ == node.succ?

    node.key = key_io.to_s
    node.val = val_io.to_s

    node.fix_succ!(succ)
    node
  end
end

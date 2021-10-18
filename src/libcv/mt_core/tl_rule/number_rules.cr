module CV::TlRule
  def fold_number!(node : MtNode) : MtNode
    node = meld_number!(node) if node.numbers?
    return node unless succ = node.succ?

    node, appro = fold_pre_quanti_appro!(node, succ)

    return node unless succ = node.succ?

    if succ.pre_dui?
      if (succ_2 = succ.succ?) && succ_2.numbers?
        succ.val = "đối"
        return fold!(node, succ_2, PosTag::Aphrase, dic: 2)
      end

      node.set!("đôi", PosTag::Quanti)
    else
      succ = heal_quanti!(succ)
      return fold_yi_verb!(node, succ) unless succ.quantis?
    end

    has_第 = node.key.starts_with?("第")

    if (prev = node.prev?) && prev.key == "第"
      has_第 = true
      prev.val = "thứ"
      node = fold!(prev, node, node.tag, dic: 1)
    end

    # has_个 = node if node.key.ends_with?('个')
    has_个 = succ if succ.key.ends_with?('个')

    appro = 1 if prev = check_pre_appro!(node.prev?)

    # merge number with quantifiers
    if !has_第
      case succ.key
      when "年" then node = fold_year!(node, succ, appro)
      when "月" then node = fold_month!(node, succ, appro)
      when "点" then node = fold_hour!(node, succ, appro)
      when "分" then node = fold_minute!(node, succ, appro)
      else
        node = fold!(node, succ, PosTag::Nquant, dic: 2)
        node = fold_suf_quanti_appro!(node) if has_个
      end
    elsif (succ_2 = succ.succ?) && succ_2.noun?
      # val = "#{succ.val} #{succ_2.val} #{node.val}"
      succ = fold!(succ, succ_2, succ_2.tag, dic: 4)
      return fold_swap!(node, succ, PosTag::Nphrase, dic: 4)
    else
      node = fold_swap!(node, succ, PosTag::Nquant, dic: 4)
    end

    if has_个 && (succ = node.succ?) && succ.quantis?
      # heal_has_个!(has_个)
      node = fold!(node, succ, PosTag::Nquant, dic: 2)
    end

    node = fold!(prev, node, node.tag, dic: 1) if prev
    fold_suf_quanti_appro!(node)
  end

  def heal_has_个!(node : MtNode)
    if node.key.size == 1
      node.val = ""
    else
      node.val = node.val.sub(" cái", "")
    end
  end

  def fold_yi_verb!(node : MtNode, succ : MtNode)
    return node unless node.key == "一" && succ.verb?
    fold_swap!(node.set!("một phát"), succ, succ.tag, dic: 5)
  end

  def check_pre_appro!(prev : MtNode?)
    return unless prev
    case prev.key
    when "近"  then prev.set!("gần")
    when "约"  then prev.set!("chừng")
    when "小于" then prev.set!("ít hơn")
    else           nil
    end
  end

  def meld_number!(node : MtNode)
    key_io = String::Builder.new(node.key)
    val_io = String::Builder.new(node.val)

    succ = node
    while succ = succ.try(&.succ?)
      if succ.numhan? || succ.numlat?
        node.tag = PosTag::Number if node.tag != succ.tag
        key_io << succ.key
        val_io << " " << succ.val
        next
      end

      if node.numhan?
        break unless (succ_2 = succ.succ?) && succ_2.numhan?
        break unless succ.key == "点"
        break if succ_2.succ?(&.key.== "分")

        key_io << succ.key << succ_2.key
        val_io << " chấm " << succ_2.val
        succ = succ_2
        next
      end

      break unless node.numlat? && (succ_2 = succ.succ?) && succ_2.numlat?

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
        break unless (succ_4 = succ_3.succ?) && succ_4.numlat?

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

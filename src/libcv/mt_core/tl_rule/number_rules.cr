module CV::TlRule
  def fold_number!(node : MtNode) : MtNode
    node = meld_number!(node)
    return node unless succ = node.succ?

    node = fold_pre_quanti_appro!(node, succ)
    has_第 = node.key.starts_with?("第")

    if prev = node.prev?
      case prev.key
      when "第"
        has_第 = true
        prev.val = "thứ"
        node = fold!(prev, node, node.tag, 2)
      when "约"
        prev.val = "chừng"
        node = fold!(prev, node, node.tag, 2)
      end
    end

    return node unless succ = node.succ?

    if succ.pre_dui?
      if (succ_2 = succ.succ?) && succ_2.numbers?
        succ.val = "đối"
        return fold!(node, succ_2, PosTag::Aphrase, 3)
      end

      node.heal!("đôi", PosTag::Quanti)
    else
      succ = heal_quanti!(succ)
      return node unless succ.quantis?
    end

    # merge number with quantifiers
    if !has_第
      node = fold!(node, succ, PosTag::Nquant, dic: 2)
    elsif (succ_2 = succ.succ?) && succ_2.noun?
      # val = "#{succ.val} #{succ_2.val} #{node.val}"
      succ = fold!(succ, succ_2, succ_2.tag, 4)
      return fold_swap!(node, succ, PosTag::Nphrase, 4)
    else
      node = fold_swap!(node, succ, PosTag::Nquant, 4)
    end

    fold_suf_quanti_appro!(node)
  end

  def meld_number!(node : MtNode)
    key_io = String::Builder.new(node.key)
    val_io = String::Builder.new(node.val)

    succ = node
    while succ = succ.succ?
      if succ.numhan? || succ.numlat?
        node.tag = PosTag::Number if node.tag != succ.tag
        key_io << succ.key
        val_io << " " << succ.val
        next
      end

      if node.numhan?
        break unless (succ_2 = succ.succ?) && succ_2.numhan?
        break unless succ.key == "点"

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

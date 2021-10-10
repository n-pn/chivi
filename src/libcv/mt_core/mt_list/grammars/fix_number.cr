module CV::MTL::Grammars
  def fix_number!(node : MtNode) : MtNode
    if node.numhan? || node.numlat?
      while succ = node.succ?
        break unless succ.numhan? || succ.numlat?
        node = node.fold!(succ)
      end
    end

    # TODO: add prefix

    node.tag == PosTag::Number
    return node unless succ

    # add suffix
    case succ.key
    when "多"
      node.fold!("hơn #{node.val}")
    when "余"
      node.fold!("trên #{node.val}")
    when "来"
      node.fold!("chừng #{node.val}")
    when "几"
      node.fold!("#{node.val} mấy")
    end

    has_第 = node.key.starts_with?("第")

    if prev = node.prev?
      case prev.key
      when "第"
        has_第 = true
        node = node.fold_left!(prev, "thứ #{node.val}")
      when "约"
        node = node.fold_left!(prev, "chừng #{node.val}")
      end
    end

    return node unless succ = node.succ?

    # handle multi meaning quantifier
    case succ.key
    when "对"
      succ_2 = succ.succ
      if succ_2.numbers? || succ_2.string?
        succ.heal!("đối", PosTag::Verb)
      else
        succ.heal!("đôi", PosTag::Quanti)
      end
    when "劫"
      succ.heal!("kiếp", PosTag::Noun)
      return node
    else
      succ = TlRule.heal_quanti!(succ)
    end

    # merge number with quantifiers
    if succ.quantis?
      if !has_第
        node.tag = PosTag::Nquant
        node.fold!("#{node.val} #{succ.val}")
      elsif succ.succ?(&.nouns?)
        succ_2 = succ.succ
        succ.fold!("#{succ.val} #{succ_2.val}")

        node.fold!("#{succ.val} #{node.val}")
        node.tag = succ_2.tag
      else
        node.tag = PosTag::Nquant
        node.fold!("#{succ.val} #{node.val}")
      end
    end

    # add extra suffixes
    return node unless succ = node.succ?

    case succ.key
    when "左右"
      node.fold!(succ, "khoảng #{node.val}")
    when "宽"
      node.fold!(succ, "rộng #{node.val}")
    when "高"
      node.fold!(succ, "cao #{node.val}")
    when "长"
      node.fold!(succ, "dài #{node.val}")
    when "重"
      node.fold!(succ, "nặng #{node.val}")
    when "远"
      node.fold!(succ, "xa #{node.val}")
    when "多"
      node.fold!(succ, "hơn #{node.val}")
    else
      return node unless succ.tag.qttime?
    end

    return node unless succ = node.succ?

    case succ.key
    when "间", "后间"
      node.fold!(succ, "khoảng #{node.val}")
    when "里", "内", "中",
         "后内", "后中"
      node.fold!(succ, "trong #{node.val}")
    when "后", "之后"
      node.fold!(succ, "sau #{node.val}")
    when "时", "之时"
      node.fold!(succ, "lúc #{node.val}")
    when "上", "之上"
      node.fold!(succ, "trên #{node.val}")
    when "下", "之下"
      node.fold!(succ, "dưới #{node.val}")
    when "前", "之前"
      node.fold!(succ, "trước #{node.val}")
    end

    node
  end
end

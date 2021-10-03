module CV::MTL::Grammars
  def fix_number!(node : MtNode) : MtNode
    while succ = node.succ?
      break unless succ.number?
      node = succ.tap(&.fuse_left!("#{node.val} "))
    end

    # TODO: add prefix

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

    case node.prev?(&.key)
    when "第"
      has_第 = true
      node.fuse_left!("thứ ")
    when "约"
      node.fuse_left!("chừng ")
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
    case succ
    when .quanti?, .nquant?, .qtverb?, .qttime?
      if !has_第
        node.fold!("#{node.val} #{succ.val}")
        node.tag = PosTag::Nquant
      elsif succ.succ?(&.nouns?)
        succ_2 = succ.succ
        succ.fold!("#{succ.val} #{succ_2.val}")

        node.fold!("#{succ.val} #{node.val}")
        node.tag = succ_2.tag
      else
        node.fold!("#{succ.val} #{node.val}")
        node.tag = PosTag::Nquant
      end
    end

    # add extra suffixes
    case node.succ?(&.key)
    when "左右"
      node.fuse_right!("khoảng #{node.val}")
    when "宽"
      node.fuse_right!("rộng #{node.val}")
    when "高"
      node.fuse_right!("cao #{node.val}")
    when "长"
      node.fuse_right!("dài #{node.val}")
    when "重"
      node.fuse_right!("nặng #{node.val}")
    when "远"
      node.fuse_right!("xa #{node.val}")
    else
      return node unless succ.tag.qttime?
    end

    case node.succ?(&.key)
    when "间", "后间"
      node.fuse_right!("khoảng #{node.val}")
    when "里", "内", "中",
         "后内", "后中"
      node.fuse_right!("trong #{node.val}")
    when "后", "之后"
      node.fuse_right!("sau #{node.val}")
    when "时", "之时"
      node.fuse_right!("lúc #{node.val}")
    when "上", "之上"
      node.fuse_right!("trên #{node.val}")
    when "下", "之下"
      node.fuse_right!("dưới #{node.val}")
    when "前", "之前"
      node.fuse_right!("trước #{node.val}")
    end

    node
  end
end

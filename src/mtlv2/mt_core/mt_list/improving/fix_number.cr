module CV::Improving
  def fix_number!(node : MtNode) : MtNode
    while succ = node.succ
      break unless succ.number?
      node = succ.tap(&.fuse_left!("#{node.val} "))
    end

    # TODO: add prefix

    return node unless succ

    # add suffix
    case succ.key
    when "多"
      node.fuse_right!("hơn #{node.val}")
    when "余"
      node.fuse_right!("trên #{node.val}")
    when "来"
      node.fuse_right!("chừng #{node.val}")
    end

    case node.prev.try(&.key)
    when "约"
      node.fuse_left!("chừng ")
    end

    return node unless succ = node.succ

    # handle multi meaning quantifier
    case succ.key
    when "石" then succ.update!("thạch", PosTag::Quanti)
    when "两" then succ.update!("lượng", PosTag::Quanti)
    when "里" then succ.update!("dặm", PosTag::Quanti)
    when "米" then succ.update!("mét", PosTag::Quanti)
    end

    # merge number with quantifiers
    case succ
    when .quanti?, .nquant?, .qtverb?, .qttime?
      node.fuse_right!("#{node.val} #{succ.val}")
      node.tag = PosTag::Nquant
    end

    # add extra suffixes
    case node.succ.try(&.key)
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

    case node.succ.try(&.key)
    when "间", "后间"
      node.fuse_right!("khoảng #{node.val}")
    when "里", "内", "中",
         "后内", "后中"
      node.fuse_right!("trong #{node.val}")
    when "后", "之后"
      node.fuse_right!("sau #{node.val}")
    when "时"
      node.fuse_right!("lúc #{node.val}")
    when "上"
      node.fuse_right!("trên #{node.val}")
    when "前"
      node.fuse_right!("trước #{node.val}")
    end

    node
  end
end

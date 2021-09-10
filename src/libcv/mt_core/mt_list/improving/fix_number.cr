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
    when "几"
      node.fuse_right!("#{node.val} mấy")
    end

    has_第 = node.key.starts_with?("第")

    case node.prev.try(&.key)
    when "第"
      has_第 = true
      node.fuse_left!("thứ ")
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
    when "帮" then succ.update!("bang", PosTag::Quanti)
    when "道" then succ.update!("đạo", PosTag::Quanti)
    when "股" then succ.update!("cỗ", PosTag::Quanti)
    when "更" then succ.update!("canh", PosTag::Quanti)
    when "重" then succ.update!("tầng", PosTag::Quanti)
    when "分" then succ.update!("phân", PosTag::Quanti)
    when "只" then succ.update!("con", PosTag::Quanti)
    when "本" then succ.update!("quyển", PosTag::Quanti)
    end

    # merge number with quantifiers
    case succ
    when .quanti?, .nquant?, .qtverb?, .qttime?
      if !has_第
        node.fuse_right!("#{node.val} #{succ.val}")
        node.tag = PosTag::Nquant
      elsif succ.succ.try(&.nouns?)
        succ_succ = succ.succ.not_nil!
        succ.fuse_right!("#{succ.val} #{succ_succ.val}")

        node.fuse_right!("#{succ.val} #{node.val}")
        node.tag = succ_succ.tag
      else
        node.fuse_right!("#{succ.val} #{node.val}")
        node.tag = PosTag::Nquant
      end
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

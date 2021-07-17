module CV::Improving
  def fix_vxiang!(node = @root) : MtNode
    return node unless succ = node.succ

    case succ
    when .verbs?
      node.update!("muốn")
    else
      # TODO!
      node
    end
  end

  def fix_vhui!(node = @root) : MtNode
    return node unless succ = node.succ

    if succ.verbs?
      return node unless succ_succ = succ.succ

      case succ_succ
      when .ude1?
        val = node.key == "不会" ? "nhất định không" : "nhất định"
        node.update!(val)
      else
        # TODO!
        node
      end
    else
      val = node.key == "不会" ? "sẽ không" : "sẽ"
      node.update!(val)
    end
  end

  def fix_verbs!(node = @root) : MtNode
    while succ = node.succ
      case succ
      when .ule?
        succ = fix_ule!(succ)
        val = succ.val.empty? ? node.val : "#{node.val} rồi"
        node.fuse_right!(val)
      when .uguo?
        node.fuse_right!("#{node.val} qua")
      when .uzhe?
        node.fuse_right!("#{node.val} lấy")
      when .nquant?
        case succ.key
        when "一趟", "一下"
          node.fuse_right!("#{node.val} #{succ.val}")
        when "一把"
          node.fuse_right!("#{node.val} một phát")
        else
          break
        end
      when .kshi?
        node.fuse_right!("lúc #{node.val}")
        node.tag = PosTag::Vintr
      else
        break
      end
    end

    while prev = node.prev
      case prev
      when .adjts?
        node.fuse_left!("", " #{prev.val}")
      when .adverb?
        node.fuse_left!("#{prev.val} ")
      else
        break
      end
    end

    node
  end
end

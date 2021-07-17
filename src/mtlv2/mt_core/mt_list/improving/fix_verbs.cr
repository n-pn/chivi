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
    return node unless succ_succ = succ.succ

    case succ_succ
    when .ude1?
      node.update!("nhất định")
    else
      # TODO!
      node
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
        else
          break
        end
      else
        break
      end
    end

    node
  end
end

module CV::MTL::Grammars
  def fix_vxiang!(node = @root) : MtNode
    return node unless succ = node.succ?

    case succ
    when .verbs?
      node.update!("muốn")
    else
      # TODO!
      node
    end
  end

  def fix_vhui!(node = @root) : MtNode
    return node unless succ = node.succ?

    if succ.verbs?
      return node unless succ_2 = succ.succ?

      case succ_2
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

  def fix_verbs!(node = @root, mode = 2) : MtNode
    return node if mode < 2

    while succ = node.succ?
      case succ
      when .ule?
        if succ.succ?(&.key.== node.key)
          node.fold!(succ, "#{node.val} #{node.val}").fold!(node.val)
        else
          succ = fix_ule!(succ)
          val = succ.val.empty? ? node.val : "#{node.val} rồi"
          node.fold!(succ, val)
        end
      when .uguo?
        node.fold!(succ, "#{node.val} qua")
      when .uzhe?
        node.fold!(succ, "#{node.val} lấy")
      when .ahao?
        node.fold!(succ, "#{node.val} tốt")
      when .nquant?
        case succ.key
        when "一趟", "一下"
          node.fuse_right!("#{node.val} #{succ.val}")
          node.tag = PosTag::Vform
        when "一把"
          node.fuse_right!("#{node.val} một phát")
          node.tag = PosTag::Vform
        end

        break
      when .suffix时?
        node = TlRule.heal_suffix_时!(node, succ)
      else
        break
      end
    end

    while prev = node.prev?
      case prev
      when .ahao?
        node.fuse_left!("thật ")
        node.tag = PosTag::Adesc
        # when .adjts?
        # node.fuse_left!("#{prev.val} ", "")
        # when .adverb?
        # node.fuse_left!("#{prev.val} ")
      else
        break
      end
    end

    node
  end
end

module CV::MTL::Grammars
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
          # do nothing
        when "一把"
          succ.val = "một phát"
        else break
        end

        node.tag = PosTag::Vform
        node.fold!(dic: 7)
        break
      when .suffix_shi?
        node = TlRule.heal_suffix_shi!(node, succ)
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
      else
        break
      end
    end

    node
  end
end

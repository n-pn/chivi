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
        if node.verb?
          succ.val = "một phát" if succ.key == "一把"
          node.tag = PosTag::Vform
          node.fold!(dic: 7)
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
      else
        break
      end
    end

    node
  end
end

module CV::MTL::Grammars
  def fix_verbs!(node = @root, mode = 1) : MtNode
    return node if mode < 1

    node.val = "thật có lỗi" if node.succ?(&.ends?) && node.key == "对不起"

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
        break unless TlRule.nquant_is_complement?(node)

        if node.key.ends_with?("把")
          node.val = node.val.sub("bả", "phát")
        end

        node.tag = PosTag::Vform
        node.fold!(dic: 6)
        break
      when .suffix_shi?
        node = TlRule.fold_suf_shi!(node, succ)
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

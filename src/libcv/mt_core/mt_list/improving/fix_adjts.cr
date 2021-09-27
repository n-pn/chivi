module CV::Improving
  def fix_adjts!(node = @head, mode = 2) : MtNode
    return node if mode < 2

    if node.amorp?
      if (succ = node.succ) && succ.adjts?
        node.fuse_right!("#{node.val} #{succ.val}")
        node.tag = PosTag::Adjt
      end
    end

    while prev = node.prev
      case prev
      when .ajno?
        break
      when .ahao?
        node.fuse_left!("thật ")
      when .adjts?
        node.fuse_left!("#{prev.val} ")
      when .adverb?
        case prev.key
        when "都"
          prev_2 = prev.prev.not_nil!

          if prev_2.key == "大家"
            prev.fuse_left!
            node.fuse_left!("mọi người đều ")
            node.tag = PosTag::Aform
          end

          break
        when "也" then break
        when "最" then node.fuse_left!("", " nhất")
        when "挺" then node.fuse_left!("rất ", "")
        else          node.fuse_left!("#{prev.val} ", "")
        end
      else
        break
      end

      node.tag = PosTag::Aform
    end

    node
  end

  # private def fix_adjts!(node = @head)
  #   while node = node.succ
  #     next unless node.adjts?

  #     prev = node.prev.not_nil!
  #     skip, left, right = false, "", ""

  #     case prev.key
  #     when "不", "很", "太", "多", "未", "更", "级", "超"
  #       skip, left = true, "#{prev.val} "
  #     when "最", "那么", "这么", "非常",
  #          "很大", "如此", "极为"
  #       skip, right = true, " #{prev.val}"
  #     when "不太"
  #       skip, left, right = true, "không ", " lắm"
  #       # else
  #       # skip, left = true, "#{prev.val} " if prev.cat == 4
  #     end

  #     node.fuse_left!(left, right) if skip
  #   end

  #   self
  # end
end

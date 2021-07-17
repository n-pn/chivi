module CV::Improving
  def fix_nouns!(node = @root) : MtNode
    if succ = node.succ
      case succ
      when .kmen?
        node.fuse_right!("các #{node.val}")
      when .ntitle?
        node.fuse_right!("#{node.val} #{succ.val}")
      end
    end

    node = nouns_fuse_left!(node)
    return node if node.prev.try(&.verbs?)

    if succ = node.succ
      case succ
      when .space?
        case succ.key
        when "上"
          node.fuse_right!("trên #{node.val}")
        else
          node.fuse_right!("#{succ.val} #{node.val}")
        end
      end
    end

    node
  end

  def nouns_fuse_left!(node) : MtNode
    return node if node.veno? || node.nother?

    while prev = node.prev
      case prev
      when .penum?
        val = prev.prev.not_nil!.val
        prev.fuse_left!
        node.fuse_left!("#{val}, ")
      when .concoord?
        prev_2 = prev.prev.not_nil!
        break unless prev_2.tag == node.tag || prev_2.pronouns?

        prev.fuse_left!("#{prev_2.val} ")
        node.fuse_left!("#{prev.val} ")
      when .number?, .nquant?, .quanti?
        node.fuse_left!("#{prev.val} ")
      when .propers?
        if node.nform?
          node.fuse_left!("#{prev.val} ")
        else
          node.fuse_left!("", " của #{prev.val}")
        end
      when .prodeic?
        case prev.key
        when .ends_with?("个")
          right = prev.val.sub("cái", "").strip
          node.fuse_left!("cái ", " #{right}")
        when .starts_with?("这")
          left = prev.val.sub("này", "").strip
          node.fuse_left!("#{left} ", " này")
        when "各"  then node.fuse_left!("các ")
        when "这"  then node.fuse_left!("", " này")
        when "其他" then node.fuse_left!("các ", " khác")
        when "任何" then node.fuse_left!("bất kỳ ")
        else           node.fuse_left!("", " #{prev.val}")
        end
      when .prointr?
        case prev.key
        when "什么" then node.fuse_left!("", " gì")
        else           node.fuse_left!("", " #{prev.val}")
        end
      when .adjts?
        case prev.key
        when "一般" then node.fuse_left!("", " thông thường")
        else           node.fuse_left!("", " #{prev.val}")
        end
      when .ude1?
        prev_2 = prev.prev.not_nil!

        case prev_2
        when .adjts?, .nquant?, .quanti?, .veno?, .nmorp?, .vintr?
          prev.fuse_left!(prev_2.val)
          node.fuse_left!("", " #{prev.val}")
        when .nouns?, .propers?
          if (prev_3 = prev_2.prev) && verb_subject?(prev_3)
            # break
            prev_2.fuse_left!("#{prev_3.val} ")
            prev.fuse_left!(prev_2.val)
            node.fuse_left!("#{node.val} #{prev.val}")
          else
            prev.fuse_left!(prev_2.val)
            node.fuse_left!("", " của #{prev.val}")
          end
        else
          break
        end
      else
        break
      end

      node.tag = PosTag::Nform
    end

    node
  end

  def verb_subject?(node : MtNode)
    return false unless node.verb?
    return true unless prev = node.prev
    prev.ends? || prev.vshi?
  end

  # private def fix_nouns!(node = @root)
  #   while node = node.succ
  #     prev = node.prev.not_nil!
  #     if node.cat == 1
  #       skip, left, right = false, "", ""

  #       case prev.key
  #       when "这", "这位", "这具", "这个", "这种",
  #            "这些", "这样", "这段", "这份", "这帮",
  #            "这条"
  #         skip, left, right = true, suffix(prev.key[1]?), " này"
  #       when "那位", "那具", "那个", "那种",
  #            "那些", "那样", "那段", "那份", "那帮",
  #            "那条"
  #         skip, left, right = true, suffix(prev.key[1]?), " kia"
  #       when "那"
  #         # TODO: skipping if 那 is in front
  #         skip, left, right = true, suffix(prev.key[1]?), " kia"
  #       when "什么"
  #         skip, right = true, " cái gì"
  #       when "没什么"
  #         skip, left, right = true, "không có ", " gì"
  #       when "这样的"
  #         skip, right = true, " như vậy"
  #       when "其他", "其她", "其它"
  #         skip, left, right = true, "cái ", " khác"
  #       when "别的"
  #         skip, right = true, " khác"
  #       when "某个"
  #         skip, right = true, " nào đó"
  #       when "一串", "一个", "一只", "几个"
  #         skip, left = true, "#{prev.val} "
  #       when "另一个"
  #         skip, left, right = true, "một cái ", " khác"
  #       end
  #       node.fuse_left!(left, right) if skip
  #     end
  #   end

  #   self
  # end
end

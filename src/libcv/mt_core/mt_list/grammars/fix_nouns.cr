module CV::MTL::Grammars
  def fix_nouns!(node = @head, mode = 1) : MtNode
    return node if mode < 1 || node.veno?

    while prev = node.prev?
      case prev
      when .penum?
        prev_2 = prev.prev
        break unless prev_2.tag == node.tag || prev_2.propers? || prev_2.prodeic?

        prev_2.tag = node.tag
        node = TlRule.fold_penum!(prev_2, prev, node, force: true)
      when .concoord?
        prev_2 = prev.prev
        break unless prev_2.tag == node.tag || prev_2.propers? || prev_2.prodeic?

        prev_2.tag = node.tag
        node = TlRule.fold_concoord!(prev_2, prev, node, force: true)
      when .nquants?
        break if node.veno? || node.ajno?
        prev.tag = PosTag::Nform
        node = prev.fold!(node)
      when .propers?
        break if prev.prev?(&.verb?)

        val = node.ptitle? ? "#{node.val} của #{prev.val}" : "#{prev.val} #{node.val}"
        node = prev.fold!(node, val)

        next
      when .prodeic?
        node.tag = PosTag::Nform

        case prev.key
        when "这"  then node = node.fold_left!(prev, "#{node.val} này")
        when "那"  then node = node.fold_left!(prev, "#{node.val} kia")
        when "各"  then node = node.fold_left!(prev, "các #{node.val}")
        when "这样" then node = node.fold_left!(prev, "#{node.val} như vậy")
        when "那样" then node = node.fold_left!(prev, "#{node.val} như thế")
        when "这个" then node = node.fold_left!(prev, "#{node.val} này")
        when "那个" then node = node.fold_left!(prev, "#{node.val} kia")
        when .ends_with?("个")
          prev.val = prev.val.sub("cái", "").strip
          node = prev.fold!(node)
        when .starts_with?("各") then node = prev.fold!(node)
        when .starts_with?("这")
          val = prev.val.sub("này", "").strip
          node = prev.fold!(node, "#{val} #{node.val} này")
        when .starts_with?("那")
          val = prev.val.sub("kia", "").strip
          node = prev.fold!(node, "#{val} #{node.val} kia")
        when "其他" then node = node.fold_left!(prev, "các #{node.val} khác")
        when "任何" then node = node.fold_left!(prev, "bất kỳ #{node.val}")
        else           node = node.fold_left!(prev, "#{node.val} #{prev.val}")
        end

        break
      when .prointr?
        val = prev.key == "什么" ? "gì đó" : prev.val
        node = node.fold_left!(prev, "#{node.val} #{val}")
      when .amorp? then node = node.fold_left!(prev)
      when .place?, .adesc?, .ahao?, .ajno?, .modifier?, .modiform?
        node = node.fold_left!(prev, "#{node.val} #{prev.val}")
      when .ajav?, .adjt?
        break if prev.key.size > 1
        node = node.fold_left!(prev, "#{node.val} #{prev.val}")
      when .ude1?
        node.succ? { |succ| break if succ.penum? || succ.concoord? }

        prev_2 = prev.prev

        case prev_2
        when .ajav?
          prev_2.val = "thông thường" if prev_2.key == "一般"

          prev_2.tag = PosTag::Nform
          prev_2.val = "#{node.val} #{prev_2.val}"
          node = prev_2.fold_many!(prev, node)
        when .adjts?, .nquant?, .quanti?, .veno?,
             .vintr?, .time?, .place?, .space?, .adesc?
          prev_2.tag = PosTag::Nform
          prev_2.val = "#{node.val} #{prev_2.val}"
          node = prev_2.fold_many!(prev, node)
        when .nouns?, .propers?
          if (prev_3 = prev_2.prev?) && verb_subject?(prev_3, node)
            prev_3.val = "#{node.val} #{prev_3.val} #{prev_2.val}"
            prev_3.tag = PosTag::Nform
            prev_3.dic = 9
            node = prev_3.fold_many!(prev_2, prev, node)
            break
          end

          prev_2.val = "#{node.val} của #{prev_2.val}"
          prev_2.tag = PosTag::Nform
          prev_2.dic = prev_2.prev?(&.verbs?) ? 8 : 7
          node = prev_2.fold_many!(prev, node)

          break
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

  def verb_subject?(head : MtNode, curr : MtNode)
    return false unless head.verb? || head.vyou?

    # return false if head.vform?

    unless prev = head.prev?
      return curr.succ? { |x| x.verbs? || x.adverbs? }
    end

    case prev.tag
    when .nouns?, .vmodal?         then return false
    when .vshi?, .verb?, .quantis? then return true
    else
      return true if prev.key == "在"
    end

    return false unless succ = curr.succ?
    succ.verbs? || succ.adverbs?
  end
end

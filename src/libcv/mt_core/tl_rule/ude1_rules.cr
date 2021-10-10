module CV::TlRule
  def fold_ude1!(node : MtNode, prev = node.prev) : MtNode
    node.succ? { |succ| return node if succ.penum? || succ.concoord? }
    prev_2 = prev.prev

    case prev_2
    when .ajav?
      prev_2.val = "thông thường" if prev_2.key == "一般"

      prev_2.tag = PosTag::Nform
      prev_2.val = "#{node.val} #{prev_2.val}"
      prev_2.fold_many!(prev, node)
    when .adjts?, .nquant?, .quanti?, .veno?,
         .vintr?, .time?, .place?, .space?, .adesc?
      prev_2.tag = PosTag::Nform
      prev_2.val = "#{node.val} #{prev_2.val}"
      prev_2.fold_many!(prev, node)
    when .nouns?, .propers?
      if (prev_3 = prev_2.prev?) && verb_subject?(prev_3, node)
        prev_3.val = "#{node.val} #{prev_3.val} #{prev_2.val}"
        prev_3.tag = PosTag::Nform
        prev_3.dic = 9
        return node = prev_3.fold_many!(prev_2, prev, node)
      end

      prev_2.val = "#{node.val} của #{prev_2.val}"
      prev_2.tag = PosTag::Nform
      prev_2.dic = prev_2.prev?(&.verbs?) ? 8 : 7
      prev_2.fold_many!(prev, node)
    else
      node
    end
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

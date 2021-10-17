module CV::TlRule
  def fold_ude1!(node : MtNode, prev = node.prev) : MtNode
    node.succ? { |succ| return node if succ.penum? || succ.concoord? }

    prev.val = ""
    prev_2 = prev.prev

    case prev_2
    when .ajav?
      prev_2.val = "thông thường" if prev_2.key == "一般"
      return fold_swap!(prev_2, node, PosTag::Nphrase, dic: 4)
    when .adjts?, .veno?, .vintr?, .time?, .place?, .space?, .adesc?
      return fold_swap!(prev_2, node, PosTag::Nphrase, dic: 4)
    when .nquants?
      # puts ["!", prev_2, prev, node]
      return fold_swap!(prev_2, node, PosTag::Nphrase, dic: 4)
    when .nouns?, .pro_per?
      # puts ["!", prev_2, prev, node]

      if (prev_3 = prev_2.prev?) && verb_subject?(prev_3, node)
        prev = fold!(prev_3, prev, PosTag::Dphrase, dic: 6)
        return fold_swap!(prev, node, PosTag::Nphrase, dic: 6)
      end

      prev.val = "của"
      dic = prev_2.prev?(&.verbs?) ? 6 : 4
      return fold_swap!(prev_2, node, PosTag::Nphrase, dic: dic)
    when .verb?
      return node

      # return node unless prev_3 = prev_2.prev?

      # if prev_3.nouns?
      #   prev_3.dic = 9
      #   prev_3.tag = PosTag::Nphrase
      #   prev_3.val = "#{node.val} #{prev_3.val} #{prev_2.val}"
      #   return prev_3.fold_many!(prev_2, prev, node)
      # elsif prev_3.nquant?
      #   prev_3.dic = 8
      #   prev_3.tag = PosTag::Nphrase
      #   prev_3.val = "#{prev_3.val} #{node.val} #{prev_2.val}"
      #   return prev_3.fold_many!(prev_2, prev, node)
      # end

      # TODO
      node
    else
      node
    end
  end

  def verb_subject?(head : MtNode, curr : MtNode)
    return false unless head.verb? || head.v_you?

    # return false if head.vform?

    unless prev = head.prev?
      return curr.succ? { |x| x.verbs? || x.adverbs? }
    end

    case prev.tag
    when .nouns?, .vmodal?          then return false
    when .v_shi?, .verb?, .quantis? then return true
    else
      return true if prev.key == "在"
    end

    return false unless succ = curr.succ?
    succ.verbs? || succ.adverbs?
  end
end

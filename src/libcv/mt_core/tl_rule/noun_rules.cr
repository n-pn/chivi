module CV::TlRule
  def fold_noun!(node : MtNode) : MtNode
    while node.nouns?
      break unless succ = node.succ?

      case succ.tag
      when .ptitle?
        node.tag = node.tag.linage? ? PosTag::Snwtit : PosTag::Person
        node.fold!(succ)
      when .names?
        break unless node.names?
        node.tag = succ.tag
        node.fold!(succ)
      when .noun?
        break unless node.names?
        node.tag = PosTag::Noun
        node.fold!(succ, "#{succ.val} #{node.val}")
      when .concoord?
        node = fold_near_concoord!(node, succ, succ.succ)
        break if node.succ == succ

        node.dic = 8
      when .penum?
        node = fold_near_penum!(node, succ, succ.succ)
        break node.succ == succ
      else break
      end
    end

    node
  end
end

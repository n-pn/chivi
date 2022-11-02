module MT::Rules
  def foldl_uzhi_base!(node : MtNode)
    case node
    when .all_nouns?
      node = foldl_noun_base!(node)
      return node unless (prev = node.prev?) && prev.verb_take_obj?
      tag, pos = PosTag.make(:vobj)
      PairNode.new(prev, node, tag, pos)
    when .adjt_words?
      foldl_adjt_base!(node)
    else
      node
    end
  end
end

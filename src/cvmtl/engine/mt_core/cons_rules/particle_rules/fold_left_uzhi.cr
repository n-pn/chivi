module MT::Core
  def fold_left_uzhi!(node : MtNode)
    case node
    when .noun_words?
      node = pair_noun!(node)
      return node unless (prev = node.prev?) && prev.verb_take_obj?
      tag, pos = PosTag::Vobj
      PairNode.new(prev, node, tag, pos)
    when .adjt_words?
      form_adjt!(node)
    else
      node
    end
  end
end

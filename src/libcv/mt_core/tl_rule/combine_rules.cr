module CV::TlRule
  def nouns_can_group?(left : MtNode, right : MtNode)
    case left.tag
    when .human? then right.human?
    when .noun?  then right.noun? || right.pro_dem?
    else              right.tag == left.tag
    end
  end

  def can_combine_adjt?(left : MtNode, right : MtNode?)
    return right.adjts?
  end

  def heal_concoord!(node : MtNode)
    node.val = "và" if node.key == "和"
    node
  end
end

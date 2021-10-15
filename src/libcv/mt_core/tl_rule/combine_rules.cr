module CV::TlRule
  def can_combine_noun?(left : MtNode, right : MtNode)
    case left.tag
    when .human?
      right.human? || right.ptitle? || right.propers?
    when .noun?
      right.noun? || right.prodeic?
    else
      right.tag == left.tag
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

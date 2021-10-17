module CV::TlRule
  def fold_suf_noun!(node : MtNode, succ : MtNode) : MtNode
    case succ.key
    when "们" then succ.val = "các"
    when "时" then succ.val = "lúc"
    end

    fold_swap!(node, succ, PosTag::Noun, dic: 7)
  end

  def fold_suf_verb!(node : MtNode, succ : MtNode) : MtNode
    # TODO: handle special cases
    fold_swap!(node, succ, PosTag::Verb, dic: 7)
  end
end

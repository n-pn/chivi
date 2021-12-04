module CV::TlRule
  def fold_suffixes!(node : MtNode, succ : MtNode) : MtNode
  end

  def fold_suf_noun!(node : MtNode, succ : MtNode) : MtNode
    case succ.key
    when "们" then succ.val = "các"
    when "时" then succ.val = "lúc"
    end

    fold!(node, succ, PosTag::Noun, dic: 7, swap: true)
  end

  def fold_suf_verb!(node : MtNode, succ : MtNode) : MtNode
    # TODO: handle special cases
    fold!(node, succ, PosTag::Verb, dic: 7, swap: true)
  end
end

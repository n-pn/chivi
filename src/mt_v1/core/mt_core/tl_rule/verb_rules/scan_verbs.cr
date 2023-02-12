module M1::TlRule
  def scan_verbs!(node : MtNode)
    node = heal_mixed!(node) if node.polysemy?

    case node
    when .v_shi?     then node
    when .v_you?     then node
    when .adverbial? then fold_adverbs!(node)
    when .verbal?    then fold_verbs!(node)
    else                  node
    end
  end
end

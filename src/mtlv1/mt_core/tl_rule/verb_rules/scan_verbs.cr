module CV::TlRule
  def scan_verbs!(node : BaseNode)
    node = heal_mixed!(node) if node.polysemy?

    case node
    when .v_shi?   then node
    when .v_you?   then node
    when .advbial? then fold_adverbs!(node)
    when .verbal?  then fold_verbs!(node)
    else                node
    end
  end
end

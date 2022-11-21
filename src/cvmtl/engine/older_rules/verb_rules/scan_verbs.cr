module MT::TlRule
  def scan_verbs!(node : MtNode)
    node = heal_mixed!(node) if node.polysemy?

    case node
    when .v_shi?      then node
    when .v_you?      then node
    when .advb_words? then fold_adverbs!(node)
    when .verbal_words? then fold_verbs!(node)
    else                   node
    end
  end
end

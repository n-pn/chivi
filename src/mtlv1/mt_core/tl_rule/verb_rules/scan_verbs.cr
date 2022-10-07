module CV::TlRule
  def scan_verbs!(node : BaseNode)
    node = heal_mixed!(node) if node.polysemy?

    case node
    when .v_shi?   then node
    when .v_you?   then node
    when .advb_words? then fold_adverbs!(node)
    when .verb_words?  then fold_verbs!(node)
    else                node
    end
  end
end

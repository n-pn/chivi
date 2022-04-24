module CV::TlRule
  def scan_verbs!(node : MtNode)
    node.adverbs? ? fold_adverbs!(node) : fold_verb!(node)
  end
end

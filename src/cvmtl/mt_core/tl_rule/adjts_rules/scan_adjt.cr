module CV::TlRule
  def scan_adjt!(node : MtNode) : MtNode
    node = fold_adverbs!(node) if node.adverbs?
    return fold_adjts!(node) if node.adjts?

    # TODO: implement code here
    node
  end
end

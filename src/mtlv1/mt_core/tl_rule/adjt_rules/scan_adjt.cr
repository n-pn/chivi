module CV::TlRule
  def scan_adjt!(node : BaseNode?) : BaseNode?
    return unless node
    node = heal_mixed!(node) if node.polysemy?

    case node
    when .modis?   then fold_modis?(node)
    when .verbal?  then fold_verbs!(node)
    when .advbial? then fold_adverbs!(node)
    when .adjts?   then fold_adjts!(node)
    when .nominal? then fold_nouns!(node)
    else                node
    end
  end
end

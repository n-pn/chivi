module M1::TlRule
  def scan_adjt!(node : MtNode?) : MtNode?
    return unless node
    node = heal_mixed!(node) if node.polysemy?

    case node
    when .modi?      then fold_modifier!(node)
    when .verbal?    then fold_verbs!(node)
    when .adverbial? then fold_adverbs!(node)
    when .adjective? then fold_adjts!(node)
    when .nominal?   then fold_nouns!(node)
    else                  node
    end
  end
end

module MT::TlRule
  def scan_adjt!(node : BaseNode?) : BaseNode?
    return unless node
    node = heal_mixed!(node) if node.polysemy?

    case node
    when .amod_words? then fold_amod_words?(node)
    when .verb_words? then fold_verbs!(node)
    when .advb_words? then fold_adverbs!(node)
    when .adjt_words? then fold_adjts!(node)
    when .noun_words? then fold_nouns!(node)
    else                   node
    end
  end
end

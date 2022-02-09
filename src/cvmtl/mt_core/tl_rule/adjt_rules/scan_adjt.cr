module CV::TlRule
  def scan_adjt!(node : MtNode?) : MtNode?
    case node
    when .nil?      then nil
    when .adverbs?  then fold_adverbs!(node)
    when .verbs?    then fold_verbs!(node)
    when .modifier? then fold_modifier!(node)
    when .ajno?     then fold_adjts!(cast_adjt!(node))
    when .adjts?    then fold_adjts!(node)
    when .nouns?    then fold_nouns!(node)
    else                 node
    end
  end
end

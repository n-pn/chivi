module CV::TlRule
  def scan_adjt!(node : MtNode?) : MtNode?
    case node
    when .nil?       then nil
    when .adverbial? then fold_adverbs!(node)
    when .verbs?     then fold_verbs!(node)
    when .modi?      then fold_modifier!(node)
    when .ajno?      then fold_adjts!(MtDict.fix_adjt!(node))
    when .adjective? then fold_adjts!(node)
    when .nominal?   then fold_nouns!(node)
    else                  node
    end
  end
end

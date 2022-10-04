module MtlV2::TlRule
  def scan_adjt!(node : BaseNode?) : BaseNode?
    case node
    when .nil?       then nil
    when .adverbial? then fold_adverbs!(node)
    when .verbal?    then fold_verbs!(node)
    when .modi?      then fold_modifier!(node)
    when .pl_ajno?   then fold_adjts!(MtDict.fix_adjt!(node))
    when .adjective? then fold_adjts!(node)
    when .nominal?   then fold_nouns!(node)
    else                  node
    end
  end
end

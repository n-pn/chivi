module MtlV2::TlRule
  def scan_verbs!(node : BaseNode)
    case node
    when .v_shi?     then node
    when .v_you?     then node
    when .adverbial? then fold_adverbs!(node)
    when .veno?      then fold_verbs!(MtDict.fix_verb!(node))
    when .verbal?    then fold_verbs!(node)
    else                  node
    end
  end
end

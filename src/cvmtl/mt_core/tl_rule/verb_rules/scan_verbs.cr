module CV::TlRule
  def scan_verbs!(node : MtNode)
    case node
    when .v_shi?   then node
    when .v_you?   then node
    when .adverbs? then fold_adverbs!(node)
    when .veno?    then fold_verbs!(MtDict.fix_verb!(node))
    when .verbs?   then fold_verbs!(node)
    else                node
    end
  end
end

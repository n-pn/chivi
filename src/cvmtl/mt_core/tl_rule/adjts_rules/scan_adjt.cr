module CV::TlRule
  def scan_adjt!(node : MtNode) : MtNode
    case node
    when .nouns?    then fold_noun!(node)
    when .adverbs?  then fold_adverbs!(node)
    when .modifier? then fold_modifier!(node)
    when .adjts?    then fold_adjts!(node)
    else                 node
    end
  end
end

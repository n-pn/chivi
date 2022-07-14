module CV::TlRule
  def fold_mixed!(node, prev = node.prev?, succ = node.succ?)
    node = heal_mixed!(node, prev, succ)

    case node.tag
    when .adverbial? then fold_adverbial!(node)
    when .adjective? then fold_adjective!(node)
    when .nominal?   then fold_nominal!(node)
    when .verbal?    then fold_verbal!(node)
    else                  node
    end
  end
end

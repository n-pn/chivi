module MT::TlRule
  def fold_puncts!(node : MtNode)
    case node.tag
    when .titleop? then fold_btitle!(node)
    when .popens?  then fold_quoted!(node)
    when .atsign?  then fold_atsign!(node)
    else                node
    end
  end
end

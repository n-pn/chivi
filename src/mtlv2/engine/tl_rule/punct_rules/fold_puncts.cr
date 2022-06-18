module MtlV2::TlRule
  def fold_puncts!(node : BaseNode)
    case node.tag
    when .titleop? then fold_btitle!(node)
    when .popens?  then fold_quoted!(node)
    when .atsign?  then fold_atsign!(node)
    else                node
    end
  end
end